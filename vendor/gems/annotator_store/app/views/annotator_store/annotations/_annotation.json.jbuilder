json.id annotation.id

# Version
json.annotator_schema_version annotation.version

# Meta
json.uri annotation.uri

# Content
json.text annotation.text
json.quote annotation.quote

language = defined?(current_user) ? AnnotatorStore::UserSetting.language_for_user(current_user) : nil

json.tags annotation.tag.present? ? [annotation.tag.path.map {|t| t.translated_name(language)}.join(' → ')] : []
json.ranges do
  json.array! annotation.ranges do |range|
    json.start range.start
    json.end range.end
    json.startOffset range.start_offset
    json.endOffset range.end_offset
  end
end

# Timestamps
json.created annotation.created_at
json.updated annotation.updated_at
