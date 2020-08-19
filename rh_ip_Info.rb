require 'json'
require 'csv'
require 'net/http'

begin
    # Define the methods we'll use below

    def get_info(ip, ipapi_key)
        ip_addr = ip
        url = "http://api.ipapi.com/#{ip_addr}?access_key=#{ipapi_key}&format=1"

        # Get the IP from IPapi.com and return
        uri = URI(url)
        Net::HTTP.get(uri)
    end

    def create_csv(headings)
        CSV.open("IP_List.csv", "w") do |csv|
            csv << headings
        end
    end

    def append_csv(json, headings)
        entry = []
        CSV.open("IP_List.csv", "a+") do |csv|
            headings.each do |loop|
                entry.append(json[loop])
            end
            csv << entry
        end
    end

    ########### Start Here ####################
    headings = ["ip", "type", "continent_code", "continent_name", "country_code", "country_name", "region_code", "region_name", "city", "zip"]
    key = "ENTER YOUR KEY HERE"

    # Take our IP address and get its information in JSON format
    output = get_info('23.251.85.70', key)
    json = JSON.parse(output)

    # Create the CSV file first, as a new clean file
    create_csv(headings)

    # Add entry to CSV
    append_csv(json, headings)
    append_csv(json, headings)


rescue => exception

end
