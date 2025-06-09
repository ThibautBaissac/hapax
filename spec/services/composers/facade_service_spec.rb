require 'rails_helper'

RSpec.describe Composers::FacadeService do
  let(:nationality) { create(:nationality) }
  let(:composer) { create(:composer, nationality: nationality) }

  describe '.paginate' do
    it 'delegates to PaginationService' do
      expect(Composers::PaginationService).to receive_message_chain(:new, :call)

      described_class.paginate(page: 1, limit: 12)
    end
  end

  describe '.create' do
    it 'delegates to CreationService' do
      params = { first_name: "Test", last_name: "Composer" }
      expect(Composers::CreationService).to receive_message_chain(:new, :call)

      described_class.create(params)
    end
  end

  describe '.update' do
    it 'delegates to UpdateService' do
      params = { first_name: "Updated" }
      expect(Composers::UpdateService).to receive_message_chain(:new, :call)

      described_class.update(composer, params)
    end
  end

  describe '.delete' do
    it 'delegates to DeletionService' do
      expect(Composers::DeletionService).to receive_message_chain(:new, :call)

      described_class.delete(composer)
    end
  end
end
