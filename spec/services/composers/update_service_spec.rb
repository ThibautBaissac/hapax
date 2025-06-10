require 'rails_helper'

RSpec.describe(Composers::UpdateService) do
  let(:nationality) { create(:nationality) }
  let(:composer) { create(:composer, nationality: nationality) }

  let(:valid_params) do
    {
      first_name: "Wolfgang Amadeus",
      last_name: "Mozart",
      nationality_id: nationality.id,
      birth_date: Date.new(1756, 1, 27),
      death_date: Date.new(1791, 12, 5),
      short_bio: "Austrian composer",
      bio: "A prolific and influential composer of classical music."
    }
  end

  let(:invalid_params) do
    {
      first_name: "",
      last_name: "",
      nationality_id: nil
    }
  end

  describe '#call' do
    context 'with valid parameters' do
      it 'updates the composer successfully' do
        service = described_class.new(composer, valid_params)
        result = service.call

        expect(result.success?).to(be(true))
        expect(service.composer.first_name).to(eq("Wolfgang Amadeus"))
        expect(service.composer.last_name).to(eq("Mozart"))
        expect(service.composer.birth_date).to(eq(Date.new(1756, 1, 27)))
      end

      it 'returns the updated composer' do
        service = described_class.new(composer, valid_params)
        service.call

        expect(service.composer).to(eq(composer))
        expect(service.composer.first_name).to(eq("Wolfgang Amadeus"))
      end

      it 'persists changes to the database' do
        service = described_class.new(composer, valid_params)
        service.call

        composer.reload
        expect(composer.first_name).to(eq("Wolfgang Amadeus"))
        expect(composer.last_name).to(eq("Mozart"))
      end
    end

    context 'with invalid parameters' do
      it 'does not update the composer' do
        original_name = composer.first_name
        service = described_class.new(composer, invalid_params)
        result = service.call

        expect(result.success?).to(be(false))
        expect(result.failure?).to(be(true))
        composer.reload
        expect(composer.first_name).to(eq(original_name))
      end

      it 'returns validation errors' do
        service = described_class.new(composer, invalid_params)
        service.call

        expect(service.errors).to(be_present)
        expect(service.errors.full_messages).to(include("First name can't be blank"))
      end
    end

    context 'with nil composer' do
      it 'fails gracefully' do
        service = described_class.new(nil, valid_params)
        result = service.call

        expect(result.success?).to(be(false))
        expect(service.errors.full_messages).to(include("Composer not found"))
      end
    end

    context 'with partial updates' do
      it 'updates only provided fields' do
        partial_params = {first_name: "Johann Sebastian"}
        original_last_name = composer.last_name

        service = described_class.new(composer, partial_params)
        service.call

        composer.reload
        expect(composer.first_name).to(eq("Johann Sebastian"))
        expect(composer.last_name).to(eq(original_last_name))
      end
    end
  end

  describe '.call' do
    it 'can be called as a class method and returns service instance' do
      result = described_class.call(composer, valid_params)

      expect(result).to(be_a(described_class))
      expect(result.success?).to(be(true))
      expect(result.composer.first_name).to(eq("Wolfgang Amadeus"))
    end

    it 'maintains backward compatibility through instance interface' do
      service = described_class.new(composer, valid_params)
      service.call

      expect(service.success?).to(be(true))
      expect(service.composer.first_name).to(eq("Wolfgang Amadeus"))
    end
  end
end
