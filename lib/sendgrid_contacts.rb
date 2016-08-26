require 'sendgrid-ruby'
require 'pry'
require "sendgrid_contacts/version"
require "json"

class SendgridContacts
  attr_accessor :sg,:list
  def initialize(contacts)
    raise "No api key given" unless ENV['SENDGRID_API_KEY']
    @sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    @recipients_ids = JSON.parse(@sg.client.contactdb.recipients.post(request_body: contacts).body)["persisted_recipients"]
  end

  def to_list(list_name)
    list_res = @sg.client.contactdb.lists.post(request_body: {name: list_name })
    if list_res.status_code == "201"
      @list = JSON.parse(list_res.body)
    else
      JSON.parse(@sg.client.contactdb.lists.get.body)["lists"].find{|e| e["name"] == list_name}
    end
    @sg.client.contactdb.lists._(@list["id"]).recipients.post(request_body: @recipients_ids)
  end

  def self.batched_import(contacts,list)
    contacts.each_slice(900).to_a.each do |batched_contacts|
      SendgridContacts.new(batched_contacts).to_list(list)
    end
  end
end
