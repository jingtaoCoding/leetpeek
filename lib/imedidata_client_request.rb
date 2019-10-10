module IMedidataClient
  class Request
    def response
      if defined?(request_body) && request_body.present?
        imedidata_connection.send(http_method, path) do |req|
          req.body = request_body.to_json
          # NOTE: The content-type header is needed because of following reasons:
          #  1. iMedidata needs to know content-type explicitly for password filtering to work in iMedidata logs.
          #  2. There's no readily available middleware as of now that can set this on all outgoing requests based
          #     on the request path.
          #  3. The activation routes that need this are not intended to be offered via Eureka-client by iMedidata, so
          #     we can't swtich to eureka-client which would have set the content-type for us.
          req.headers['Content-Type'] = 'application/json'
        end
      else
        imedidata_connection.send(http_method, path)
      end
    end

    def http_method
      raise IMedidataClientError, 'No default http method. Please define an http method for the subclass.'
    end

    def request_body
      {}
    end

    def imedidata_connection
      @connection ||= Faraday.new(url: IMED_BASE_URL) do |builder|
        builder.use MAuth::Faraday::RequestSigner, mauth_client: MAUTH_CLIENT
        builder.use Aranea::Faraday::FailureSimulator if ENV['USE_ARANEA']
        builder.adapter Faraday.default_adapter
      end
    end
  end

  class AppRequest < Request
    attr_accessor :study_uuid

    def self.required_attributes
      [:study_uuid]
    end

    def initialize(attrs = {})
      @study_uuid = attrs[:study_uuid]
    end

    def path
      "api/v2/studies/#{@study_uuid}/apps.json"
    end

    def request_body
      ''
    end

    def http_method
      :get
    end
  end

  class UserAuthenticationRequest < Request
    attr_accessor :login, :password

    def self.required_attributes
      %i[login password]
    end

    def initialize(attrs = {})
      @login = attrs[:login]
      @password = attrs[:password]
    end

    def request_body
      { password: { primary_password: password } }
    end

    def path
      "/api/v2/users/#{login}/authenticate.json"
    end

    def http_method
      :post
    end
  end

  class UserCreationRequest < Request
    attr_accessor :login, :first_name, :last_name, :locale, :time_zone, :telephone

    def self.required_attributes
      %i[login first_name last_name locale time_zone telephone]
    end

    def initialize(attrs = {})
      @login = attrs[:login]
      @first_name = attrs[:first_name]
      @last_name = attrs[:last_name]
      @locale = attrs[:locale]
      @time_zone = attrs[:time_zone]
      @telephone = attrs[:telephone]
    end

    def instance_attributes
      self.class.required_attributes.each_with_object({}) { |sym, hsh| hsh[sym] = send(sym); }
    end

    def request_body
      instance_attributes.merge(email: instance_attributes[:login])
    end

    def path
      '/api/v2/users.json'
    end

    def http_method
      :post
    end
  end

  class UserActivationRequest < Request
    attr_accessor :imedidata_activation_code, :password, :security_question_id, :answer, :eula_agreed_to

    def self.required_attributes
      %i[password security_question_id answer eula_agreed_to]
    end

    def initialize(attrs = {})
      @imedidata_activation_code = attrs[:imedidata_activation_code]
      @password = attrs[:password]
      @security_question_id = attrs[:security_question_id]
      @answer = attrs[:answer]
      @eula_agreed_to = attrs[:eula_agreed_to]
    end

    def request_body
      {
        password: password,
        user_security_question: {
          security_question_id: security_question_id,
          answer: answer
        },
        eula_agreed_to: eula_agreed_to
      }
    end

    def path
      "/api/v2/created_users/#{imedidata_activation_code}/activate.json"
    end

    def http_method
      :put
    end
  end

  class NewUserActivationRequest < Request
    attr_accessor :first_name, :last_name, :locale, :time_zone, :telephone, :login,
                  :password, :email, :user_security_question

    def self.required_attributes
      %i[first_name last_name locale time_zone telephone login password email user_security_question]
    end

    def initialize(attrs = {})
      @first_name = attrs[:first_name]
      @last_name = attrs[:last_name]
      @locale = attrs[:locale]
      @time_zone = attrs[:time_zone]
      @telephone = attrs[:telephone]
      @login = attrs[:login]
      @password = attrs[:password]
      @email = attrs[:email]
      @user_security_question = attrs[:user_security_question]
    end

    def instance_attributes
      self.class.required_attributes.each_with_object({}) { |sym, hsh| hsh[sym] = send(sym); }
    end

    def request_body
      instance_attributes
    end

    def path
      '/api/v2/users/activate.json'
    end

    def http_method
      :post
    end
  end

  class UserStudySitesRequest < Request
    attr_accessor :user_uuid, :study_uuid

    def self.required_attributes
      %i[user_uuid study_uuid]
    end

    def initialize(attrs = {})
      @user_uuid = attrs[:user_uuid]
      @study_uuid = attrs[:study_uuid]
    end

    def path
      "/api/v2/users/#{user_uuid}/studies/#{study_uuid}/study_sites.json"
    end

    def http_method
      :get
    end
  end

  class CreatedUserGetRequest < Request
    attr_accessor :user_uuid

    def self.required_attributes
      [:user_uuid]
    end

    def initialize(attrs = {})
      @user_uuid = attrs[:user_uuid]
    end

    def path
      "api/v2/created_users/#{user_uuid}.json"
    end

    def request_body; end

    def http_method
      :get
    end
  end

  class StudyRequest < Request
    attr_accessor :study_uuid

    def initialize(attrs = {})
      @study_uuid = attrs[:study_uuid]
    end

    def path
      "api/v2/studies/#{@study_uuid}.json"
    end

    def request_body; end

    def http_method
      :get
    end
  end
end