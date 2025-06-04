require 'rails_helper'

describe EdgerydersShared::ActionsController do
  before do
    SiteSetting.queue_jobs = false
  end

  it 'can list' do
    sign_in(Fabricate(:user))
    get "/edgeryders-shared/list.json"
    expect(response.status).to eq(200)
  end
end
