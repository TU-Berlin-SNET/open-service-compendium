shared_context 'with existing providers' do
  before :each do
    3.times { create(:provider) }
  end

  after :each do
    Provider.delete_all
  end
end