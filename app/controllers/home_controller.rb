class HomeController < ApplicationController
  def index
    @zipcode_req = params[:zipcode] || "94040"
    fetchData(@zipcode_req)
  end

  def search
    @zipcode_req = params[:zipcode]

    if @zipcode_req == ""
      redirect_to action: "index"
    else
      redirect_to action: "index", zipcode: @zipcode_req
    end
  end

  private
    def fetchData(zipcode)
      require "net/http"
      require "json"

      # 94040
      url = URI("https://#{Rails.application.credentials.api[:host]}/api/weather/air_pollution?zip=#{zipcode}%2CUS&type=current")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request["x-rapidapi-key"] = Rails.application.credentials.api[:key]
      request["x-rapidapi-host"] = Rails.application.credentials.api[:host]
      request["Accept"] = "application/json"

      response = http.request(request)
      if response.kind_of? Net::HTTPSuccess
        parse = JSON.parse(response.read_body)
        @result = parse["list"][0]["main"]["aqi"]
        if @result <= 50
          @background = "green"
        @description = "Good (0 - 50)"
        elsif @result <= 100
          @background = "yellow"
        @description = "Moderate (51 - 100)"
        elsif @result <= 150
          @background = "orange"
        @description = "Unhealthy for Sensitive Groups (USG) (101 - 150)"
        elsif @result <= 200
          @background = "red"
        @description = "Unhealthy (151 - 200)"
        elsif @result <= 300
          @background = "purple"
        @description = "Very Unhealthy (201 - 300)"
        else
          @background = "maroon"
        @description = "Hazardous (301+)"
        end
      else
        @result = "No data found"
        @background = "bg-light"
        @description = "data error"
      end
    end
end
