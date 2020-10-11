(ns handler
  (:require [cheshire.core :as json]
            [clojure.string :as str]
            [clj-http.lite.client :as http])
  (:import (java.time ZonedDateTime Duration)))

(defn make-task-status [event]
  (let [{:keys [detail]} event
        {:keys [startedBy startedAt stoppedAt desiredStatus taskDefinitionArn containers]} detail
        task-def (last (str/split taskDefinitionArn #"/"))
        started-by-rule? (and startedBy (.startsWith startedBy "events-rule"))]
    (if started-by-rule?
      (when (and startedAt stoppedAt)
        (let [startedAt (ZonedDateTime/parse startedAt)
              stoppedAt (ZonedDateTime/parse stoppedAt)
              duration (Duration/between startedAt stoppedAt)
              exit-codes (into {}
                               (map (fn [{:keys [exitCode name]}]
                                      [exitCode name]))
                               containers)]
          (str "Task " task-def " finished "
               (if (= #{0} (set (keys exit-codes)))
                 "succefully "
                 (str "with container exit codes\n"
                      (str/join "\n" (map (fn [[exit-code name]]
                                            (str "  " name ": " exit-code))
                                          exit-codes))
                      "\n"))
               "after " (format "%dm %ds"
                                (.toMinutes duration)
                                (mod (.getSeconds duration) 60)))))
      (str/join "\n" (into [(str "Task " task-def
                                 (when startedBy
                                   (str " started by " startedBy))
                                 " targeting status " desiredStatus)]
                           (map (fn [{:keys [name lastStatus]}]
                                  (str "container " name " is now " lastStatus)))
                           containers)))))

(defn ecs-task-state-change? [{:keys [detail-type]}]
  (= "ECS Task State Change" detail-type))

(defn handle [event _context]
  (when (ecs-task-state-change? event)
    (when-let [status-text (make-task-status event)]
      (http/post (System/getenv "SLACK_WEBHOOK_URL")
                 {:body (json/generate-string {:text status-text})})))
  (println (json/generate-string event)))
