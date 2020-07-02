# Graphryder plugin for Discourse

This is a plugin designed to install and use [RedisGraph](https://oss.redislabs.com/redisgraph/) with a Discourse instance.

It uses the existing redis installation baked into Discourse into order to construct a graph of relationships between nodes.

Currently, a built binary of the RedisGraph module (version [2.0.11-rc1](https://github.com/RedisGraph/RedisGraph/releases/tag/2.0.11-rc1)) is included with this plugin, and installed on Discourse startup, which allows storing nodes and edges within Redis.

### Installation

Instructions for installing Discourse plugins [can be found here](https://meta.discourse.org/t/install-plugins-in-discourse/19157).

Take note that the first time this plugin is installed, it will install the [RedisGraph module](https://oss.redislabs.com/redisgraph/#loading-redisgraph-into-redis) onto Discourse's Redis instance. Subsequent deploys will not perform this step.

Once the plugin is running, it will begin auto-syncing updates which occur.

Starting the instance with the `GRAPHRYDER_IMPORT` ENV variable set will cause a full import of the existing database from Postgres into RedisGraph.

```bash
GRAPHRYDER_IMPORT bundle exec rails s
```

### API

This plugin exposes a single endpoint,
```
/graphryder/query
```
which accepts a [RedisGraph query](https://oss.redislabs.com/redisgraph/commands/), and responds with

It will return a hash with keys, one for each `RETURN` value in the query. For instance, the following query:

```js
{
  "query": "MATCH (post:post) RETURN post, count(*) as count"
}
```
would return JSON as follows:
```js
{
  "post": [{...}, {...}, {...}, {...}, {...}], // json representations of post data stored in RedisGraph
  "count": 5 // Number of records returned
}
```

In order to use this endpoint, a user must either be authenticated as an admin (using a generated Admin API key), or a member of a group named `annotators`

At the time of this writing, the intended consumer of this API is the [Existing graphryder API](https://github.com/edgeryders/graphryder-api)


### Data model

As of this writing, the fields synced to RedisGraph are as follows:
```
User:
  fields:
    label (username)
    avatar (avatar_template)
    timestamp (updated_at)
    url (https://<instance>.com/users/<username>)

Topic:
  fields:
    label (id)
    title (title)
    timestamp (updated_at)
    url (url)

  relationships:
    AUTHORSHIP (user)

Post:
  fields:
    label (id)
    topic_id (topic_id)
    number (post_number)
    content (cooked)
    timestamp (updated_at)
    url (url)

  relationships:
    AUTHORSHIP (user)
    COMMENTS (topic)
    COMMENTS (reply_to_post)

AnnotatorStore::Tag
  fields:
    label (id)
    name (name)
    description (description)
    timestamp (updated_at)

  relationships:
    AUTHORSHIP (creator)

AnnotatorStore::TagName
  fields:
    label (name)
    timestamp (updated_at)

  relationships:
    NAMED (tag)

AnnotatorStore::Annotation
  fields:
    label (id)
    quote (quote)
    timestamp (updated_at)

  relationships:
    AUTHORSHIP (user)
    REFERS_TO (tag)

```

The code which does this can be viewed [in the Updater class](./app/services/updater.rb) (the code written there should be considered the source of truth)
