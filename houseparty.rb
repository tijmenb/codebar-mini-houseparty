require 'httparty'
require 'trello'

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_API_KEY']
  config.member_token = ENV['TRELLO_MEMBER_TOKEN']
end

query = {
  api_key: ENV['ZOOPLA_API_KEY'],
  order_by: 'age',
  listing_status: 'rent',
  furnished: 'unfurnished',
  maximum_price: ((1500 * 12) / 52).to_i,
  minimum_beds: '1',
  area: 'Hackney, London',
}

response = HTTParty.get(
  'https://api.zoopla.co.uk/api/v1/property_listings.json',
  query: query,
  format: :json
)

listings = response.parsed_response['listing']

board = Trello::Board.find('HMKRAEKm')

incoming_list = Trello::List.create(
  name: 'New listings',
  board_id: board.id
)

listings.each do |listing|
  Trello::Card.create(
    name: listing['displayable_address'],
    desc: listing['details_url'],
    list_id: incoming_list.id
  )
end
