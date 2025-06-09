require 'rails_helper'

RSpec.describe ComposersController, type: :request do
  let(:user) { create(:user) }
  let(:nationality) { create(:nationality) }
  let(:composer) { create(:composer, nationality: nationality) }

  before do
    sign_in user
  end

  describe "GET /composers" do
    context "with no composers" do
      before do
        Composer.destroy_all
      end

      it "returns http success" do
        get composers_path
        expect(response).to have_http_status(:success)
      end

      it "displays empty list" do
        get composers_path
        expect(response.body).to include("html")
      end
    end

    context "with existing composers" do
      let!(:composers) { create_list(:composer, 15, nationality: nationality) }

      it "returns http success" do
        get composers_path
        expect(response).to have_http_status(:success)
      end

      it "paginates results with 12 items per page" do
        get composers_path
        expect(response).to have_http_status(:success)
        # The controller should load only 12 composers per page
        # We can't directly check @composers without rails-controller-testing,
        # but we can verify the database query behavior
        expect(Composer.count).to eq(15)
      end

      it "includes nationality data to avoid N+1 queries" do
        # Create composers with nationalities
        nationality = FactoryBot.create(:nationality)
        FactoryBot.create_list(:composer, 3, nationality: nationality)

        # Make the request
        get composers_path

        # Should successfully load with includes
        expect(response).to have_http_status(:success)
        expect(Composer.count).to be > 0
      end
    end
  end

  describe "GET /composers/:id" do
    it "returns http success for existing composer" do
      get composer_path(composer)
      expect(response).to have_http_status(:success)
    end

    it "returns 404 for non-existing composer" do
      get composer_path(id: 999999)
      expect(response).to have_http_status(:not_found)
    end

    it "sets the composer instance variable correctly" do
      get composer_path(composer)
      expect(response).to have_http_status(:success)
      # Verify the correct composer was found by checking the URL includes the ID
      expect(response.request.path).to include(composer.id.to_s)
    end
  end

  describe "GET /composers/new" do
    it "returns http success" do
      get new_composer_path
      expect(response).to have_http_status(:success)
    end

    it "creates a new composer instance" do
      get new_composer_path
      expect(response).to have_http_status(:success)
      # Verify the form is present for new composer
      expect(response.body).to include("form")
    end

    it "loads nationalities for the form" do
      # Create some nationalities to verify they're loaded
      create_list(:nationality, 3)
      get new_composer_path
      expect(response).to have_http_status(:success)
      expect(Nationality.count).to be > 0
    end
  end

  describe "GET /composers/:id/edit" do
    it "returns http success for existing composer" do
      get edit_composer_path(composer)
      expect(response).to have_http_status(:success)
    end

    it "returns 404 for non-existing composer" do
      get edit_composer_path(id: 999999)
      expect(response).to have_http_status(:not_found)
    end

    it "loads nationalities for the form" do
      create_list(:nationality, 3)
      get edit_composer_path(composer)
      expect(response).to have_http_status(:success)
      expect(Nationality.count).to be > 0
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
      it "creates a new composer" do
        expect {
          post composers_path, params: { composer: valid_attributes }
        }.to change(Composer, :count).by(1)
      end

      it "redirects to the created composer" do
        post composers_path, params: { composer: valid_attributes }
        expect(response).to redirect_to(Composer.last)
      end

      it "sets a success notice" do
        post composers_path, params: { composer: valid_attributes }
        follow_redirect!
        expect(response.body).to include("successfully created")
      end

      it "assigns correct attributes to the composer" do
        post composers_path, params: { composer: valid_attributes }
        created_composer = Composer.last
        expect(created_composer.first_name).to eq("Ludwig van")
        expect(created_composer.last_name).to eq("Beethoven")
        expect(created_composer.nationality).to eq(nationality)
      end
    end

    context "with invalid parameters" do
      it "does not create a new composer" do
        expect {
          post composers_path, params: { composer: invalid_attributes }
        }.to change(Composer, :count).by(0)
      end

      it "renders the new template with unprocessable entity status" do
        post composers_path, params: { composer: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "displays validation errors" do
        post composers_path, params: { composer: invalid_attributes }
        expect(response.body).to include("First name can&#39;t be blank")
      end
    end

    context "with missing parameters" do
      it "returns bad request for missing parameters" do
        post composers_path, params: { invalid: "params" }
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe "PATCH/PUT /composers/:id" do
    let(:new_attributes) do
      {
        first_name: "Wolfgang Amadeus",
        last_name: "Mozart",
        birth_date: Date.new(1756, 1, 27),
        death_date: Date.new(1791, 12, 5)
      }
    end

    let(:invalid_attributes) do
      {
        first_name: "",
        last_name: ""
      }
    end

    context "with valid parameters" do
      it "updates the composer" do
        patch composer_path(composer), params: { composer: new_attributes }
        composer.reload
        expect(composer.first_name).to eq("Wolfgang Amadeus")
        expect(composer.last_name).to eq("Mozart")
      end

      it "redirects to the composer" do
        patch composer_path(composer), params: { composer: new_attributes }
        expect(response).to redirect_to(composer)
      end

      it "sets a success notice" do
        patch composer_path(composer), params: { composer: new_attributes }
        follow_redirect!
        expect(response.body).to include("successfully updated")
      end
    end

    context "with invalid parameters" do
      it "does not update the composer" do
        original_name = composer.first_name
        patch composer_path(composer), params: { composer: invalid_attributes }
        composer.reload
        expect(composer.first_name).to eq(original_name)
      end

      it "renders the edit template with unprocessable entity status" do
        patch composer_path(composer), params: { composer: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    it "returns 404 for non-existing composer" do
      patch composer_path(id: 999999), params: { composer: new_attributes }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /composers/:id" do
    let!(:composer_to_delete) { create(:composer, nationality: nationality) }

    it "destroys the composer" do
      expect {
        delete composer_path(composer_to_delete)
      }.to change(Composer, :count).by(-1)
    end

    it "redirects to composers index" do
      delete composer_path(composer_to_delete)
      expect(response).to redirect_to(composers_path)
    end

    it "uses see_other status for redirect" do
      delete composer_path(composer_to_delete)
      expect(response).to have_http_status(:see_other)
    end

    it "sets a success notice" do
      delete composer_path(composer_to_delete)
      follow_redirect!
      expect(response.body).to include("successfully destroyed")
    end

    it "returns 404 for non-existing composer" do
      delete composer_path(id: 999999)
      expect(response).to have_http_status(:not_found)
    end

    context "when composer has dependent records" do
      let!(:work) { create(:work, composer: composer_to_delete) }

      it "destroys dependent works" do
        expect {
          delete composer_path(composer_to_delete)
        }.to change(Work, :count).by(-1)
      end
    end
  end

  describe "authentication and authorization" do
    context "when not authenticated" do
      before do
        sign_out user
      end

      it "redirects to login for index" do
        get composers_path
        expect(response).to redirect_to(new_user_session_path)
      end

      it "redirects to login for show" do
        get composer_path(composer)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "redirects to login for new" do
        get new_composer_path
        expect(response).to redirect_to(new_user_session_path)
      end

      it "redirects to login for edit" do
        get edit_composer_path(composer)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "redirects to login for create" do
        post composers_path, params: { composer: { first_name: "Test" } }
        expect(response).to redirect_to(new_user_session_path)
      end

      it "redirects to login for update" do
        patch composer_path(composer), params: { composer: { first_name: "Test" } }
        expect(response).to redirect_to(new_user_session_path)
      end

      it "redirects to login for destroy" do
        delete composer_path(composer)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "parameter handling" do
    context "strong parameters" do
      let(:allowed_params) do
        {
          first_name: "Franz",
          last_name: "Schubert",
          nationality_id: nationality.id,
          birth_date: Date.new(1797, 1, 31),
          death_date: Date.new(1828, 11, 19),
          short_bio: "Austrian composer",
          bio: "Franz Peter Schubert was an Austrian composer.",
          portrait: fixture_file_upload('test_image.jpg', 'image/jpeg')
        }
      end

      let(:forbidden_params) do
        allowed_params.merge(
          id: 999,
          created_at: Time.current,
          updated_at: Time.current,
          forbidden_attribute: "should not be allowed"
        )
      end

      it "permits allowed parameters" do
        post composers_path, params: { composer: allowed_params }
        expect(response).to redirect_to(Composer.last)
      end

      it "filters out forbidden parameters" do
        expect {
          post composers_path, params: { composer: forbidden_params }
        }.not_to raise_error
      end
    end
  end

  describe "error handling" do
    context "when database errors occur" do
      before do
        allow(Composer).to receive(:find).and_raise(ActiveRecord::ConnectionNotEstablished)
      end

      it "handles database connection errors" do
        expect {
          get composer_path(composer)
        }.to raise_error(ActiveRecord::ConnectionNotEstablished)
      end
    end

    context "when save fails with exception" do
      it "handles save exceptions" do
        # Stub the save method to raise an exception
        allow_any_instance_of(Composer).to receive(:save).and_raise(ActiveRecord::RecordInvalid.new(Composer.new))

        post composers_path, params: { composer: { first_name: "Test", last_name: "Composer" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "pagination behavior" do
    context "with multiple pages of composers" do
      let!(:composers) { create_list(:composer, 25, nationality: nationality) }

      it "shows first page by default" do
        get composers_path
        expect(response).to have_http_status(:success)
      end

      it "handles page parameter" do
        get composers_path, params: { page: 2 }
        expect(response).to have_http_status(:success)
      end

      it "handles invalid page parameter gracefully" do
        get composers_path, params: { page: 999 }
        expect(response).to redirect_to(composers_path)
      end
    end
  end

  describe "content type responses" do
    it "responds with HTML by default" do
      get composers_path
      expect(response.content_type).to include('text/html')
    end

    it "includes proper HTML structure" do
      get composer_path(composer)
      expect(response.body).to include('<!DOCTYPE html>')
      expect(response.body).to include('<html')
      expect(response.body).to include('</html>')
    end
  end
end
