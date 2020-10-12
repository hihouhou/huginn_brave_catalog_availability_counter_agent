module Agents
  class BraveCatalogAvailabilityCounterAgent < Agent
    include FormConfigurable
    can_dry_run!
    no_bulk_receive!
    default_schedule '1h'

    description do
      <<-MD
      The Brave catalog availability counter agent fetches metrics about how many campaigns / creative instanceids are available.

      `debug` is used to verbose mode.

      `expected_receive_period_in_days` is used to determine if the Agent is working. Set it to the maximum number of days
      that you anticipate passing without this Agent receiving an incoming Event.
      MD
    end

    event_description <<-MD
      Events look like this:
        {
          "date": "2020-10-10T09:05:22+02:00",
          "campaign_number": "12",
          "creatives_number": "18",
          "creativeinstanceid_number": "61"
        }
    MD

    def default_options
      {
        'debug' => 'false',
        'expected_receive_period_in_days' => '2',
      }
    end

    form_configurable :debug, type: :boolean
    form_configurable :expected_receive_period_in_days, type: :string
    def validate_options

      if options.has_key?('debug') && boolify(options['debug']).nil?
        errors.add(:base, "if provided, debug must be true or false")
      end

      unless options['expected_receive_period_in_days'].present? && options['expected_receive_period_in_days'].to_i > 0
        errors.add(:base, "Please provide 'expected_receive_period_in_days' to indicate how many days can pass before this Agent is considered to be not working")
      end
    end

    def working?

      return false if recent_error_logs?

      if interpolated['expected_receive_period_in_days'].present?
        return false unless last_receive_at && last_receive_at > interpolated['expected_receive_period_in_days'].to_i.days.ago
      end

      true
    end

    def check
      fetch
    end

    private

    def fetch
      uri = URI.parse("https://ads-serve.brave.com/v4/catalog")
      response = Net::HTTP.get_response(uri)

      puts "request  status : #{response.code}"

      payload = JSON.parse(response.body)

      if interpolated['debug'] == 'true'
        log payload
      end
      
      campaign_nbr=0
      creativesets_nbr=0
      creatives_nbr=0
      creativeinstanceid_nbr=0
      payload['campaigns'].each do |campaign|
        if interpolated['debug'] == 'true'
          log campaign
        end
        campaign_nbr +=1
        campaign['creativeSets'].each do |creativesets|
          if interpolated['debug'] == 'true'
            log creativesets
          end
          creatives_nbr +=1
          creativesets['creatives'].each do |creatives|
            if interpolated['debug'] == 'true'
              log creatives
            end
            creativeinstanceid_nbr +=1
          end
        end
      end
      log "campaign number : #{campaign_nbr}"
      create_event :payload => { 'date' => "#{DateTime.now()}", 'campaign_number' => "#{campaign_nbr}", 'creatives_number' => "#{creatives_nbr}", 'creativeinstanceid_number' => "#{creativeinstanceid_nbr}" }
    end
  end
end
