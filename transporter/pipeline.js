otto({"filename": "test/transformers/passthrough_and_log.js"})

var source = mongodb({
  "uri": "${MONGODB_URI}"
  // "fsync": false,
  // "bulk": false,
  // "collection_filters": "{}",
  // "read_preference": "Primary"
})

var es_sink = elasticsearch({
  "uri": "${ELASTICSEARCH_URI}"
  // "timeout": "10s", // defaults to 30s
  // "parent_id": "elastic_parent" // defaults to "elastic_parent" parent identifier for Elasticsearch
})


t.Source("source", source) .Save("es", es_sink)
