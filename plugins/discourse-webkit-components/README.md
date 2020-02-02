# Discourse plugin for webkit component endpoints

This plugin exposes endpoints to act as a data source for the [Edgeryders webkit component kit](https://github.com/edgeryders/webkit_components)

## Endpoints

This API currently features 3 endpoints:

### Topics

```
https://edgeryders.eu/webkit_components/topics.json
```

#### Endpoint specific options

- Tags

  ```
  https://edgeryders.eu/webkit_components/topics.json?tags=webcontent-festival-stories
  ```

  This option narrows down topics to ones that have _any_ of the comma-delimited tags. This allows for more granular control of the topics which are returned.

- Categories

  ```
  https://edgeryders.eu/webkit_components/topics.json?categories=festival
  ```

  This option narrows down topics to ones that have _any_ of the comma-delimited categories. This allows for more granular control of the topics which are returned.

### Categories

```
https://edgeryders.eu/webkit_components/categories.json
```

This displays a list of categories on the site, excluding those specified by environment variable.

#### Endpoint specific options

- Excluded categories

  The `WEBKIT_EXCLUDED_CATEGORIES` ENV variable will hold a comma-delimited list of category slugs that should not be returned in this query; e.g.

  ```
  WEBKIT_EXCLUDED_CATEGORIES=campfire,workspaces,knowledge-collection
  ```

    (^^ TODO: convert this to a site setting so admins can manage it without a deploy)

### Users

```
https://edgeryders.eu/webkit_components/users.json
```

This displays a list of users on the site, sorted by those who have most recently posted.

## Common Endpoint options

All endpoints share the following options:

- `serializer`

  ```
  https://edgeryders.eu/webkit_components/<noun>.json?serializer=event
  ```

  This option changes the serializer used to render the json. Certain use cases (such as displaying events or organizers) may have additional information included with the serialized result.

  Currently only topics have multiple serializer options, which are:
  - `topic` (default)
  - `event` (includes time, location, and a confirmed flag)
  - `organizer` (includes a bio and username for an organizer)


- `from`

  ```
  https://edgeryders.eu/webkit_components/<noun>.json?from=10
  ```

  This option determines where in the list of results to start from, for the purposes of pagination. Default is 0 (display from the first record)

- `per`

  ```
  https://edgeryders.eu/webkit_components/<noun>.json?per=10
  ```

  This option determines how many objects to list in the result, for the purposes of pagination. Default is 50 (display up to 50 records in the result)
