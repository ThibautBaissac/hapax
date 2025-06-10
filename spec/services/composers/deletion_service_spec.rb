require 'rails_helper'

RSpec.describe(Composers::DeletionService) do
  let(:nationality) { create(:nationality) }
  let(:composer) { create(:composer, nationality: nationality) }

  describe '#call' do
    context 'with valid composer' do
      it 'deletes the composer successfully' do
        service = described_class.new(composer)

        expect { service.call }.to(change(Composer, :count).by(-1))
        expect(service.success?).to(be(true))
        expect(service.composer).to(eq(composer))
      end

      it 'returns the deleted composer' do
        service = described_class.new(composer)
        service.call

        expect(service.composer).to(eq(composer))
      end

      it 'removes the composer from the database' do
        composer_id = composer.id
        service = described_class.new(composer)
        service.call

        expect { Composer.find(composer_id) }.to(raise_error(ActiveRecord::RecordNotFound))
      end
    end

    context 'with nil composer' do
      it 'fails gracefully' do
        service = described_class.new(nil)
        result = service.call

        expect(result.success?).to(be(false))
        expect(service.errors.full_messages).to(include("Composer not found"))
      end

      it 'does not change composer count' do
        expect { described_class.new(nil).call }.not_to(change(Composer, :count))
      end
    end

    context 'when deletion fails' do
      before do
        # Simulate a scenario where deletion might fail
        allow(composer).to(receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed.new("Cannot delete")))
      end

      it 'handles deletion errors gracefully' do
        service = described_class.new(composer)
        result = service.call

        expect(result.success?).to(be(false))
        expect(service.errors.full_messages).to(include("Could not delete composer: Cannot delete"))
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(composer).to(receive(:destroy!).and_raise(StandardError.new("Unexpected error")))
      end

      it 'handles unexpected errors gracefully' do
        service = described_class.new(composer)
        result = service.call

        expect(result.success?).to(be(false))
        expect(service.errors.full_messages).to(include("An unexpected error occurred: Unexpected error"))
      end
    end

    context 'with associated records' do
      let!(:work) { create(:work, composer: composer) }
      let!(:movement) { create(:movement, work: work) }

      it 'deletes composer and cascades to associated records' do
        service = described_class.new(composer)

        expect { service.call }.to(change(Composer, :count).by(-1)
                                 .and(change(Work, :count).by(-1)
                                 .and(change(Movement, :count).by(-1))))

        expect(service.success?).to(be(true))
      end
    end
  end

  describe '.call' do
    it 'can be called as a class method' do
      result = described_class.call(composer)

      expect(result.success?).to(be(true))
      expect { Composer.find(composer.id) }.to(raise_error(ActiveRecord::RecordNotFound))
    end
  end

  describe 'transaction behavior' do
    context 'when deletion succeeds' do
      it 'commits the transaction' do
        service = described_class.new(composer)

        expect(ApplicationRecord).to(receive(:transaction).and_call_original)
        service.call

        expect(service.success?).to(be(true))
      end
    end

    context 'when deletion fails' do
      before do
        allow(composer).to(receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed.new("Cannot delete")))
      end

      it 'rolls back the transaction' do
        original_count = Composer.count
        service = described_class.new(composer)
        service.call

        expect(Composer.count).to(eq(original_count))
        expect(service.success?).to(be(false))
      end
    end
  end
end
