require 'rails_helper'

RSpec.describe Composers::PaginationService do
  let(:nationality) { create(:nationality) }
  let!(:composers) { create_list(:composer, 25, nationality: nationality) }

  describe '#call' do
    context 'with default parameters' do
      it 'returns paginated results' do
        service = described_class.new
        pagy, composers = service.call

        expect(pagy).to be_a(Pagy)
        expect(pagy.limit).to eq(12)
        expect(pagy.page).to eq(1)
        expect(composers.count).to eq(12)
      end
    end

    context 'with custom parameters' do
      it 'respects page and limit parameters' do
        service = described_class.new(page: 2, limit: 5)
        pagy, composers = service.call

        expect(pagy.page).to eq(2)
        expect(pagy.limit).to eq(5)
        expect(composers.count).to eq(5)
      end
    end

    context 'with invalid page' do
      it 'defaults to page 1' do
        service = described_class.new(page: 0)
        pagy, _composers = service.call

        expect(pagy.page).to eq(1)
      end
    end

    context 'when page exceeds available data' do
      it 'raises Pagy::OverflowError' do
        service = described_class.new(page: 999)

        expect { service.call }.to raise_error(Pagy::OverflowError)
      end
    end

    it 'includes nationality to avoid N+1 queries' do
      service = described_class.new
      _pagy, composers = service.call

      expect { composers.first.nationality.name }.not_to raise_error
    end
  end
end
