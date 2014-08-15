shared_context 'with existing clients' do
  before :each do
    Client.with(safe: true).delete_all

    3.times { create(:client) }
  end
end