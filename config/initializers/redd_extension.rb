require 'redd'
module Redd::Client::Authenticated::PrivateMessages
  def mark_many_read(messages)
    fullnames = messages.map { |m| extract_fullname(message) }

    post "/api/read_message", id: fullnames.join(',')
  end
end