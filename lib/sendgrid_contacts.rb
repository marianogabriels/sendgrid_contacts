require "sendgrid_contacts/version"
require "json"

class SendgridContacts
  attr_accessor :sg,:list
  def initialize(contacts)
    @sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    @recipients_ids = JSON.parse(sg.client.contactdb.recipients.post(request_body: contacts)).body["persisted_recipients"]
  end

  def to_list(list_name)
    @list =  JSON.parse(@sg.client.contactdb.lists.post(request_body: {name: list_name }))
    @sg.client.contactdb.lists._(@list["id"]).recipients.post(request_body: @recipients_ids)
  end
end
