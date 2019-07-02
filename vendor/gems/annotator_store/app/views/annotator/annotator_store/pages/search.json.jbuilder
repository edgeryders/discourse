json.total @total
json.rows do
  json.array! @annotations, partial: 'annotator/annotator_store/annotations/annotation', as: :annotation, current_user: @current_user
end
