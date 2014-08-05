shared_context 'with existing clients' do
  before :each do
    3.times { create(:client) }
  end

  after :each do
    Client.delete_all
  end
end