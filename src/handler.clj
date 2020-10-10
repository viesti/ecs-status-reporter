(ns handler
  (:require [cheshire.core :as json]
            [clojure.string :as str]
            [clj-http.lite.client :as http]))

(defn make-task-status [event]
  (let [{:keys [detail]} event
        {:keys [startedBy desiredStatus taskDefinitionArn containers]} detail
        task-def (last (str/split taskDefinitionArn #"/"))]
    (str/join "\n" (into [(str "Task " task-def
                               (when startedBy
                                 (str " started by " startedBy))
                               " targeting status " desiredStatus)]
                         (map (fn [{:keys [name lastStatus]}]
                                (str "container " name " is now " lastStatus)))
                         containers))))

(defn ecs-task-state-change? [event]
  (= "ECS Task State Change" (:detail-type event)))

(defn handle [event _context]
  (when (ecs-task-state-change? event)
    (http/post (System/getenv "SLACK_WEBHOOK_URL")
               {:body (json/generate-string {:text (make-task-status event)})}))
  (println (json/generate-string event)))
