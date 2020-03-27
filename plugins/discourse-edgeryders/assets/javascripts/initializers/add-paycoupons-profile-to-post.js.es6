import { withPluginApi } from 'discourse/lib/plugin-api';

function addPayCouponsIcon(api) {


    api.decorateWidget('poster-name:after', helper => {
      const post = helper.getModel();
      const paycouponsUsername = post.poster_paycoupons_username;

      if (!Ember.isEmpty(paycouponsUsername)) {
        return helper.h('span.post-icon', [
          helper.h('a.paycoupons-icon', {
            href:'https://www.pay.coupons/'+paycouponsUsername,
            title: 'I offer PayCoupons',
            target:'_blank'
          }, helper.h('img', {height: '16', src:'data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCEtLSBDcmVhdGVkIHdpdGggSW5rc2NhcGUgKGh0dHA6Ly93d3cuaW5rc2NhcGUub3JnLykgLS0+Cjxzdmcgd2lkdGg9Ijg4Ljk3Mm1tIiBoZWlnaHQ9IjcxLjkwNW1tIiB2ZXJzaW9uPSIxLjEiIHZpZXdCb3g9IjAgMCAzMTUuMjU1MDEgMjU0Ljc3OTk1IiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOmNjPSJodHRwOi8vY3JlYXRpdmVjb21tb25zLm9yZy9ucyMiIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1sbnM6b3NiPSJodHRwOi8vd3d3Lm9wZW5zd2F0Y2hib29rLm9yZy91cmkvMjAwOS9vc2IiIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiA8bWV0YWRhdGE+CiAgPHJkZjpSREY+CiAgIDxjYzpXb3JrIHJkZjphYm91dD0iIj4KICAgIDxkYzpmb3JtYXQ+aW1hZ2Uvc3ZnK3htbDwvZGM6Zm9ybWF0PgogICAgPGRjOnR5cGUgcmRmOnJlc291cmNlPSJodHRwOi8vcHVybC5vcmcvZGMvZGNtaXR5cGUvU3RpbGxJbWFnZSIvPgogICAgPGRjOnRpdGxlLz4KICAgPC9jYzpXb3JrPgogIDwvcmRmOlJERj4KIDwvbWV0YWRhdGE+CiA8ZyB0cmFuc2Zvcm09InRyYW5zbGF0ZSgtNDQzNDQgLTI4MjAuOSkiPgogIDxnIHRyYW5zZm9ybT0ibWF0cml4KC45ODkzMSAwIDAgLjk4OTMxIDQyODkuMyAyODc5LjQpIj4KICAgPHBhdGggZD0ibTQwNjg2LTU5LjE1NmMtMi42MzItMC4wMzc2LTUuMjg1IDAuNjEzNC03LjcwNyAyLjAxMTlsLTgwLjc2NCA0Ni42MjgtMjEuNTcxIDEyLjQ1My04MC43NjIgNDYuNjNjLTcuMzgzIDQuMjYyNi05LjgxMyAxMy44NTItNS4yNDQgMjEuNzY2bDU3LjQxOSA5OS40NTNjMC4zNTMgMC42MTA4NyAwLjc0NSAxLjE4MDkgMS4xNTMgMS43Mjg3bC0yOC40NDItMTA2LjE1Yy0zLjM3Ni0xMi41OTkgMy43MjgtMjUuNjQ5IDE2LjA1OC0yOC45NTNsOTAuMDc3LTI0LjEzNyAyNC4wNjEtNi40NDgzIDcxLjE2Ny0xOS4wNjktMjEuNjgxLTM3LjU1NmMtMi44NTYtNC45NDYyLTcuNjQ4LTcuODUzNi0xMi42NDEtOC4yOTc0LTAuMzc0LTAuMDMzMy0wLjc0Ny0wLjA1MjQtMS4xMjMtMC4wNTc0em02MC43NDYgNDcuNjU5Yy0wLjQ0NC0wLjAxNjEtMC44OTEtMC4wMTEyLTEuMzQgMC4wMTMtMS4wMjUgMC4wNTU0LTIuMDU4IDAuMjE4NC0zLjA4NyAwLjQ5NDE4bC05LjM2NSAyLjUwOTgtNy41ODEgMi4wMzIyLTczLjEzMyAxOS41OTMtMjQuMDU3IDYuNDQ4My05MC4wODMgMjQuMTM3Yy04LjIzNSAyLjIwNjUtMTMuMDYyIDEwLjg0LTEwLjY5NiAxOS42NjdsMjkuMDQ5IDEwOC40MnYtMTA0LjUxYzAtMTMuMDQzIDEwLjI0LTIzLjgxMSAyMy4wMDUtMjMuODExaDE5My40M2wtMTEuNDcyLTQyLjgwM2MtMS45NC03LjI0MDgtOC4wMDYtMTEuOTUxLTE0LjY3LTEyLjE5MnptLTE2Ny4yOSA2Mi41NzVjLTguNTI1IDAtMTUuNDI0IDcuMDkyLTE1LjQyNCAxNi4yM2wtMC4wNSAxMTcuMzVjMC4xMDUgNC4xODk5IDEuODcyIDYuNTY4NiA0LjYzNiA5LjEwNjIgMi45NDYgMi43MDQ1IDYuNjA5IDQuNjE0MiAxMC44MzQgNC42MTQyaDIxMS40M2M4LjUyNCAwIDE1LjQyMS03LjA5IDE1LjQyMS0xNi4yMjh2LTExNC44NGMwLTkuMTM4My02Ljg5Ny0xNi4yMy0xNS40MjEtMTYuMjNoLTExOC4xN3oiIGZpbGwtcnVsZT0iZXZlbm9kZCIvPgogIDwvZz4KIDwvZz4KPC9zdmc+Cg=='}) )
        ]);

      }

    });

}

export default {
  name: 'add-paycoupons-profile-to-post',

  initialize() {
    withPluginApi('0.1', addPayCouponsIcon);
  }
};
