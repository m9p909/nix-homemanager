---
name: babashka
description: Reference for writing babashka (bb) scripts in Clojure. Use when generating bb scripts, shell automation, or Clojure CLI tooling.
model: inherit
color: green
---

## Babashka Quick Reference

Use this when writing babashka (`bb`) scripts.

### Command Line Args

```clojure
(def my-args *command-line-args*)
```

### Reading Stdin

```clojure
(doseq [line (line-seq (clojure.java.io/reader *in*))]
  (println (clojure.string/upper-case line)))
```

### Run Shell Commands

```clojure
(require '[babashka.process :refer [shell]])
(shell "whoami")
```

### Set Environment Variable for Shell Command

```clojure
(require '[babashka.process :refer [shell]])
(shell {:extra-env {"FOO" "bar"}} "printenv" "FOO")
```

### Capture Output of a Shell Command

```clojure
(require '[babashka.process :refer [sh]])
(def myname (:out (sh ["whoami"])))
```

### Spawn a Shell Command in the Background

```clojure
(require '[babashka.process :refer [shell process]])

(let [p (process ["sh" "-c" "for i in `seq 3`; do date; sleep 1; done"]
                 {:out :inherit, :err :inherit})]
  (println "Waiting for result...")
  @p)
```

### Read Command Output Line by Line

```clojure
(require '[babashka.process :as p :refer [process destroy-tree]]
         '[clojure.java.io :as io])

(let [stream (process
              {:err :inherit
               :shutdown destroy-tree}
              ["cat" "/etc/hosts"])]
  (with-open [rdr (io/reader (:out stream))]
    (binding [*in* rdr]
      (loop []
        (when-let [line (read-line)]
          (println (str "#" line))
          (recur)))))
  (p/destroy-tree stream)
  nil)
```

Or simpler:

```clojure
(let [p (shell {:out :string} "cat" "/etc/hosts")]
  (doseq [line (clojure.string/split-lines (:out p))]
    (println (str "#" line))))
```

### Find Project Folder

```clojure
;; Must be at top level, not inside a function
(def project-root (-> *file* babashka.fs/parent babashka.fs/parent))
(println (str project-root))
```

### Copy, Move, Delete, Read and Write Files

```clojure
(require '[babashka.fs :as fs])

(spit "world" "hello\n")
(fs/copy "world" "world2")
(spit "world2" "world\n" :append true)
(fs/delete "world")
(fs/move "world2" "world")
(print (slurp "world"))

(println (str (fs/file project-root "README.txt")))
```

### Dates and Times

```clojure
(defn iso-date []
  (-> (java.time.LocalDateTime/now)
      (.format (java.time.format.DateTimeFormatter/ISO_LOCAL_DATE))))

(defn iso-date-hm []
  (-> (java.time.LocalDateTime/now)
      (.format (java.time.format.DateTimeFormatter/ofPattern "yyyy-MM-dd---kk-mm"))))

(def fname (str "backup-" (iso-date) ".zip"))
```

### HTTP Calls

```clojure
(require '[cheshire.core :as cheshire]
         '[org.httpkit.client :as http])

(defn fetch-data [url params]
  (-> @(http/get url {:query-params params})
      :body
      (cheshire/decode true)))
```
