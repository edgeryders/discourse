module Graphryder
  class Updater
    include Rails.application.routes.url_helpers

    def self.initialize!
      ::User.class_eval do
        after_save :graphryder_sync

        def is_annotator?
          admin? || groups.find_by(name: :annotator)
        end

        def graphryder_url
          "#{Discourse.base_url}/users/#{username}"
        end

        def graphryder_sync
          ::Graphryder::Query.instance.perform "
            MERGE (user:user {id:#{id}})
            SET user.label = '#{username}',
                user.avatar = '#{avatar_template}',
                user.timestamp = '#{updated_at}',
                user.url = '#{graphryder_url}'
            RETURN user
          "
        end
      end

      ::TopicTag.class_eval do
        after_save :graphryder_sync

        def graphryder_sync
          ::Graphryder::Query.instance.perform "
            MERGE (topic:topic {id:#{topic_id}})
            MERGE (tag:tag {id:#{tag_id}})
            MERGE (topic)-[:REFERS_TO]->(tag)
            RETURN topic, tag
          "
        end
      end

      ::Topic.class_eval do
        after_save :graphryder_sync

        def graphryder_sync
          ::Graphryder::Query.instance.perform "
            MERGE (topic:topic {id:#{id}})
            SET topic.label = '#{id}',
                topic.title = '#{title.gsub("\'", "’")}',
                topic.timestamp = '#{updated_at}',
                topic.url = '#{url}'
            MERGE (user:user {id:#{user_id}})
            MERGE (user)-[:AUTHORSHIP]->(topic)
            RETURN topic
          "
        end
      end

      ::Post.class_eval do
        after_save :graphryder_sync

        def graphryder_sync
          ::Graphryder::Query.instance.perform "
            MERGE (post:post {id:#{id}})
            SET post.label = '#{id}',
                post.topic_id = '#{topic_id}',
                post.number = '#{post_number}',
                post.content = '#{cooked.gsub("\'", "’")}',
                post.timestamp = '#{updated_at}',
                post.url = '#{url}'
            MERGE (user:user {id:#{user_id}})
            MERGE (topic:topic {id:#{topic_id}})
            MERGE (user)-[:AUTHORSHIP]->(post)
            MERGE (post)-[:COMMENTS]->(topic)
            #{"
              MERGE (parent:post {topic_id:#{topic_id}, post_number:#{reply_to_post_number}})
              MERGE (post)-[:COMMENTS]->(parent)
            " if reply_to_post_number}
            RETURN post
          "
        end
      end

      ::Tag.class_eval do
        after_save :graphryder_sync

        def graphryder_sync
          ::Graphryder::Query.instance.perform "
            MERGE (tag:tag {id:#{id}})
            SET tag.label = '#{name.downcase}',
                tag.timestamp = '#{updated_at}',
                tag.url = '#{full_url}'
            #{"
              MERGE (target:tag {id:#{target_tag_id}})
              MERGE (target)-[:IS_CHILD]->(tag)
            " if target_tag_id}

            RETURN tag
          "
        end
      end

      ::AnnotatorStore::Annotation.class_eval do
        after_save :graphryder_sync

        def graphryder_sync
          ::Graphryder::Query.instance.perform "
            MERGE (annotation:annotation {id:#{id}})
            SET annotation.label = '#{id}',
                annotation.quote = '#{quote.gsub("\'", "’")}',
                annotation.timestamp = '#{updated_at}'
            MERGE (user:user {id:#{creator_id}})
            MERGE (user)-[:AUTHORSHIP]->(annotation)
            #{"
              MERGE (tag:tag {id:#{tag_id}})
              MERGE (annotation)-[:REFERS_TO]->(tag)
            " if tag_id}
            #{"
              MERGE (post:post {id:#{post_id}})
              MERGE (annotation)-[:ANNOTATES]->(post)
            " if post_id}
            #{"
              MERGE (topic:topic {id:#{topic_id}})
              MERGE (annotation)-[:ANNOTATES]->(topic)
            " if topic_id}
            RETURN annotation
          "
        end
      end if Object.const_defined?("AnnotatorStore::Annotation")
    end
  end
end
