require File.expand_path '../spec_helper.rb', __FILE__

describe 'BLE Server' do
  it 'should allow accessing the home page' do
    get '/'
    expect(last_response).to be_ok
  end

  it 'should download all contacts as a Json' do
    get '/api/v1/contacts'
    expect(last_response).to be_ok
  end

  it 'should insert an event' do
    post '/api/v1/contacts', {
      uploader: 'uploaderID',
      contact: 'contactID',
      date: '2020-03-19T07:22Z',
      rssi: -27
    }.to_json, as: :json

    expect(last_response).to be_ok
    json_response = JSON.parse(last_response.body)

    expect(json_response['uploader']).to eq('uploaderID')
    expect(json_response['contact']).to eq('contactID')
    expect(json_response['start_time']).to eq('2020-03-19T07:22:00.000Z')
    expect(json_response['end_time']).to eq('2020-03-19T07:22:00.000Z')
    expect(json_response['rssi']).to eq(-27)
  end

  it 'should not duplicate events' do
    post '/api/v1/contacts', {
      uploader: 'uploaderID',
      contact: 'contactID',
      date: '2020-03-19T07:22Z',
      rssi: -27
    }.to_json, as: :json

    post '/api/v1/contacts', {
      uploader: 'uploaderID',
      contact: 'contactID',
      date: '2020-03-19T07:22Z',
      rssi: -27
    }.to_json, as: :json

    expect(last_response).to be_ok
    json_response = JSON.parse(last_response.body)

    expect(json_response['uploader']).to eq('uploaderID')
    expect(json_response['contact']).to eq('contactID')
    expect(json_response['start_time']).to eq('2020-03-19T07:22:00.000Z')
    expect(json_response['end_time']).to eq('2020-03-19T07:22:00.000Z')
    expect(json_response['rssi']).to eq(-27)

    # has only one record
    get '/api/v1/contacts'
    expect(last_response).to be_ok
    json_response = JSON.parse(last_response.body)
    expect(json_response.length).to eq(1)
  end

  it 'should create new records if diferent contacts' do
    post '/api/v1/contacts', {
      uploader: 'uploaderID',
      contact: 'contactID',
      date: '2020-03-19T07:22Z',
      rssi: -27
    }.to_json, as: :json

    post '/api/v1/contacts', {
      uploader: 'uploaderID',
      contact: 'contactID2',
      date: '2020-03-19T07:22Z',
      rssi: -27
    }.to_json, as: :json

    expect(last_response).to be_ok
    json_response = JSON.parse(last_response.body)

    expect(json_response['uploader']).to eq('uploaderID')
    expect(json_response['contact']).to eq('contactID2')
    expect(json_response['start_time']).to eq('2020-03-19T07:22:00.000Z')
    expect(json_response['end_time']).to eq('2020-03-19T07:22:00.000Z')
    expect(json_response['rssi']).to eq(-27)

    # has only one record
    get '/api/v1/contacts'
    expect(last_response).to be_ok
    json_response = JSON.parse(last_response.body)
    expect(json_response.length).to eq(2)
  end

  it 'should update end time of events with less than 3 minute distances' do
    post '/api/v1/contacts', {
      uploader: 'uploaderID',
      contact: 'contactID',
      date: '2020-03-19T07:22Z',
      rssi: -27
    }.to_json, as: :json

    expect(last_response).to be_ok

    post '/api/v1/contacts', {
      uploader: 'uploaderID',
      contact: 'contactID',
      date: '2020-03-19T07:23Z',
      rssi: -27
    }.to_json, as: :json

    expect(last_response).to be_ok
    json_response = JSON.parse(last_response.body)

    expect(json_response['start_time']).to eq('2020-03-19T07:22:00.000Z')
    expect(json_response['end_time']).to eq('2020-03-19T07:23:00.000Z')
    expect(json_response['rssi']).to eq(-27)

    # has only one record
    get '/api/v1/contacts'
    expect(last_response).to be_ok
    json_response = JSON.parse(last_response.body)
    expect(json_response.length).to eq(1)
  end

  it 'should update start time of events with less than 3 minute distances' do
    post '/api/v1/contacts', {
      uploader: 'uploaderID',
      contact: 'contactID',
      date: '2020-03-19T07:22Z',
      rssi: -27
    }.to_json, as: :json

    expect(last_response).to be_ok

    post '/api/v1/contacts', {
      uploader: 'uploaderID',
      contact: 'contactID',
      date: '2020-03-19T07:21Z',
      rssi: -27
    }.to_json, as: :json

    expect(last_response).to be_ok
    json_response = JSON.parse(last_response.body)

    expect(json_response['start_time']).to eq('2020-03-19T07:21:00.000Z')
    expect(json_response['end_time']).to eq('2020-03-19T07:22:00.000Z')
    expect(json_response['rssi']).to eq(-27)

    # has only one record
    get '/api/v1/contacts'
    expect(last_response).to be_ok
    json_response = JSON.parse(last_response.body)
    expect(json_response.length).to eq(1)
  end

  it 'should insert events with more than 3 minute distances' do
    post '/api/v1/contacts', {
      uploader: 'uploaderID',
      contact: 'contactID',
      date: '2020-03-19T07:22Z',
      rssi: -27
    }.to_json, as: :json

    expect(last_response).to be_ok
    json_response = JSON.parse(last_response.body)

    expect(json_response['start_time']).to eq('2020-03-19T07:22:00.000Z')
    expect(json_response['end_time']).to eq('2020-03-19T07:22:00.000Z')
    expect(json_response['rssi']).to eq(-27)

    post '/api/v1/contacts', {
      uploader: 'uploaderID',
      contact: 'contactID',
      date: '2020-03-19T07:27Z',
      rssi: -27
    }.to_json, as: :json

    expect(last_response).to be_ok
    json_response = JSON.parse(last_response.body)

    expect(json_response['start_time']).to eq('2020-03-19T07:27:00.000Z')
    expect(json_response['end_time']).to eq('2020-03-19T07:27:00.000Z')
    expect(json_response['rssi']).to eq(-27)

    # has only one record
    get '/api/v1/contacts'
    expect(last_response).to be_ok
    json_response = JSON.parse(last_response.body)
    expect(json_response.length).to eq(2)
  end

  it 'should only update RSSI when inside range' do
    post '/api/v1/contacts', {
      uploader: 'uploaderID',
      contact: 'contactID',
      date: '2020-03-19T07:22Z',
      rssi: -27
    }.to_json, as: :json

    expect(last_response).to be_ok
    json_response = JSON.parse(last_response.body)

    p json_response
    expect(json_response['start_time']).to eq('2020-03-19T07:22:00.000Z')
    expect(json_response['end_time']).to eq('2020-03-19T07:22:00.000Z')
    expect(json_response['rssi']).to eq(-27)

    post '/api/v1/contacts', {
      uploader: 'uploaderID',
      contact: 'contactID',
      date: '2020-03-19T07:24:30Z',
      rssi: -28
    }.to_json, as: :json

    expect(last_response).to be_ok
    json_response = JSON.parse(last_response.body)
    p json_response
    expect(json_response['start_time']).to eq('2020-03-19T07:22:00.000Z')
    expect(json_response['end_time']).to eq('2020-03-19T07:24:30.000Z')
    expect(json_response['rssi']).to eq(-28)

    post '/api/v1/contacts', {
      uploader: 'uploaderID',
      contact: 'contactID',
      date: '2020-03-19T07:24Z',
      rssi: -29
    }.to_json, as: :json

    expect(last_response).to be_ok
    json_response = JSON.parse(last_response.body)

    expect(json_response['start_time']).to eq('2020-03-19T07:22:00.000Z')
    expect(json_response['end_time']).to eq('2020-03-19T07:24:30.000Z')
    expect(json_response['rssi']).to eq(-29)

    # has only one record
    get '/api/v1/contacts'
    expect(last_response).to be_ok
    json_response = JSON.parse(last_response.body)
    expect(json_response.length).to eq(1)
  end
end