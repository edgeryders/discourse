json.total @total
json.rows do
  json.array! @annotations, partial: 'annotator_store/annotations/annotation', as: :annotation, current_user: @current_user
end
