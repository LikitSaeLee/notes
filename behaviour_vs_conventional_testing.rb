class PollService
  def initialize(_user_id)
    @user_id
  end

  def get(poll_name)
    poll = Poll.find_by(user_id: @user_id, poll_name: poll_name)

    return poll.data if poll.present?

    nil
  end

  def save(poll_name, poll_data)
    Poll.create(user_id: @user_id, poll_name: poll_name, poll_data: poll_data)
  end

  def answered?(poll_name)
    Poll.find_by(user_id: @user_id, poll_name: poll_name).present?
  end
end

# Conventional
# 1. Test by methods
# 2. Test every branches
# 3. Test internal implementation (How Poll got saved).
Rspec.describe PollService do
  let(:user_id) { 1 }
  let(:poll_name) { 'Hapiness Poll' }
  let(:poll_data) do
    { 'Are you good?' => 'Yes!' }
  end

  let(:poll_service) do
    PollService.new(user_id)
  end

  describe '#save' do
    it 'saves the poll data' do
      expect { poll_service.save(poll_name, poll_data) }.to change { Poll.count }.by(1)
    end

    it 'saves the poll data correctly' do
      poll_service.save(poll_name, poll_data)

      poll_created = Poll.last

      expect(poll_created).to have_attributes(user_id: user_id, poll_name: poll_name, poll_data: poll_data)
    end
  end

  describe '#answered' do
    context 'when user answered the poll' do
      before do
        Poll.create(user_id: user_id, poll_name: poll_name, poll_data: poll_data)
      end

      it 'returns true' do
        expect(poll_service.answered?).to be true
      end
    end

    context 'when user does not answer the poll' do
      it 'returns false' do
        expect(poll_service.answered?).to be false
      end
    end
  end

  describe '#poll_data' do
    context 'when user answered the poll' do
      before do
        Poll.create(user_id: user_id, poll_name: poll_name, poll_data: poll_data)
      end

      it 'returns poll_data' do
        data = poll_service.get(poll_name)
        expect(data).to eq('Are you good?' => 'Yes')
      end
    end

    context 'when user does not answer the poll' do
      it 'returns nil' do
        data = poll_service.get(poll_name)

        expect(data).to be nil
      end
    end
  end
end

# BDD
# 1. Test by use cases
# 2. Does not test internal implementations
# 3. How do you know that you've cover everything? Test coverage / You dont need to
#    because you're not using it that way.
Rspec.describe PollService do
  let(:user_id) { 1 }

  let(:poll_name) { 'Hapiness Poll' }

  let(:poll_data) do
    { 'Are you good?' => 'Yes!' }
  end

  let(:poll_service) do
    PollService.new(user_id)
  end

  context 'when user answered the poll' do
    before do
      poll_service.save(poll_name, poll_data)
    end

    it 'tells answered is true' do
      expect(poll_service.answered?(poll_name)).to be true
    end

    it 'returns the poll data' do
      data = poll_service.get(poll_name)
      expect(data).to eq('Are you good?' => 'Yes')
    end
  end

  context 'when user did not answered the poll' do
    it 'tells answered is false' do
      expect(poll_service.answered?(poll_name)).to be false
    end

    it 'returns nil as poll data' do
      expect(poll_service.get(poll_name)).to be_nil
    end
  end
end

