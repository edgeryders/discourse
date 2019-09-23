import { acceptance } from "helpers/qunit-helpers";

acceptance("EdgerydersShared", { loggedIn: true });

test("EdgerydersShared works", async assert => {
  await visit("/admin/plugins/edgeryders-shared");

  assert.ok(false, "it shows the EdgerydersShared button");
});
