require 'rails_helper'

RSpec.describe ComposersController, type: :request do
  let(:user) { create(:user) }
  let(:nationality) { create(:nationality) }
  let(:composer) { create(:composer, nationality: nationality) }

  before { sign_in user }

  describe "GET /composers" do
    context "with existing composers" do
      let!(:composers) { create_list(:composer, 15, nationality: nationality) }

      it "returns paginated results using the service" do
        get "/composers"

        expect(response).to have_http_status(:success)
        expect(Composer.count).to eq(15)
      end

      it "handles pagination overflow gracefully" do
        get "/composers", params: { page: 999 }

        expect(response).to redirect_to("/composers")
      end
    end
  end

  describe "POST /composers" do
    let(:valid_attributes) do
      {
        first_name: "Ludwig van",
        last_name: "Beethoven",
        nationality_id: nationality.id,
        birth_date: Date.new(1770, 12, 17),
        death_date: Date.new(1827, 3, 26),
        short_bio: "German composer",
        bio: "A German composer and pianist."
      }
    end

    let(:invalid_attributes) do
      {
        first_name: "",
        last_name: "",
        nationality_id: nationality.id
      }
    end

    context "with valid parameters" do
      it "creates a new composer using the service" do
        expect {
          post "/composers", params: { composer: valid_attributes }
        }.to change(Composer, :count).by(1)

        expect(response).to redirect_to(Composer.last)
      end

      it "sets success message" do
        post "/composers", params: { composer: valid_attributes }
        follow_redirect!
        expect(response.body).to include("successfully created")
      end
    end

    context "with invalid parameters" do
      it "does not create composer" do
        expect {
          post "/composers", params: { composer: invalid_attributes }
        }.not_to change(Composer, :count)
      end

      it "renders new template with errors" do
        post "/composers", params: { composer: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /composers/:id" do
    let(:new_attributes) do
      {
        first_name: "Wolfgang Amadeus",
        last_name: "Mozart"
      }
    end

    context "with valid parameters" do
      it "updates composer using the service" do
        patch "/composers/#{composer.id}", params: { composer: new_attributes }

        composer.reload
        expect(composer.first_name).to eq("Wolfgang Amadeus")
        expect(response).to redirect_to(composer)
      end
    end

    context "with invalid parameters" do
      it "does not update composer" do
        original_name = composer.first_name

        patch "/composers/#{composer.id}", params: {
          composer: { first_name: "", last_name: "" }
        }

        composer.reload
        expect(composer.first_name).to eq(original_name)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /composers/:id" do
    let!(:composer_to_delete) { create(:composer, nationality: nationality) }

    it "destroys composer using the service" do
      expect {
        delete "/composers/#{composer_to_delete.id}"
      }.to change(Composer, :count).by(-1)

      expect(response).to redirect_to("/composers")
      expect(response).to have_http_status(:see_other)
    end

    it "sets success message" do
      delete "/composers/#{composer_to_delete.id}"
      follow_redirect!
      expect(response.body).to include("successfully destroyed")
    end
  end

  describe "error handling" do
    context "when service fails" do
      it "handles creation service errors gracefully" do
        # Create a mock errors object that behaves like ActiveModel::Errors
        mock_errors = double("service_errors")
        allow(mock_errors).to receive(:each).and_yield(
          double("error", attribute: :first_name, message: "can't be blank")
        )
        allow(mock_errors).to receive(:full_messages).and_return(["First name can't be blank"])

        mock_service = double("service")
        allow(mock_service).to receive(:success?).and_return(false)
        allow(mock_service).to receive(:composer).and_return(nil)
        allow(mock_service).to receive(:errors).and_return(mock_errors)

        post "/composers", params: { composer: { first_name: "Test" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "authentication" do
    context "when not authenticated" do
      before { sign_out user }

      it "redirects to login" do
        get "/composers"
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
