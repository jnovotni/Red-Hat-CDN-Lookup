require 'json'
require 'csv'
require 'net/http'

begin
    # Define the methods we'll use below
    def get_ip_list
        ips = Array.new
        uri = URI("https://access.redhat.com/sites/default/files/cdn_redhat_com_cac.json")
        # Fetch the IP Address list from Red Hat's Knowledgebase
        ip_list_json = JSON.parse(Net::HTTP.get(uri))
        # Go through the returned JSON and grab the IP's
        ip_list_json["cidr_list"].each do |hash|
            ips.append(hash["ip_prefix"])
        end
        # Strip off the /32 from the IP as we don't need the subnet
        ips.map!{ |element| element.gsub("/32", '') }
        return ips
    end

    def get_info(ip, ipapi_key)
        # Get the IP from IPapi.com and return
        uri = URI("http://api.ipapi.com/#{ip}?access_key=#{ipapi_key}&format=1&fields=main")
        output = Net::HTTP.get(uri)
        JSON.parse(output)
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

    def get_key
        puts
        puts "################# API Key Required to run ###############################",""
        puts "Signup for a free API key at  ( https://ipapi.com/signup/free )", "Then, Fetch your API key from the dashboard ( https://ipapi.com/dashboard )",""
        puts "##########################################################################"
        printf "Please enter your ipapi.com API Key: "
        key = gets.strip
        return key
    end

    ########### Start Here ####################
    headings = ["ip", "type", "continent_code", "continent_name", "country_code", "country_name", "region_code", "region_name", "city", "zip", "latitude", "longitude"]
    key = ARGV[0] || key = nil
    ip_array = get_ip_list
    if key.nil?
        key = get_key()
    end

    # Create the CSV file first, as a new clean file
    create_csv(headings)

    # Cycle through the IP List array and fetch its information from IPAPI.com, then update the CSV with the gathered information
    ip_array.each do |loop|
        append_csv((get_info(loop, key)), headings)
    end

rescue => exception

end
