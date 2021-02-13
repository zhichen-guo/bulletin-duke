class Challenge < ApplicationRecord
    has_and_belongs_to_many :users

    def self.hours_total(start_date, end_date, user)
        hrs = 0
        if user.nil?
            Opportunity.all.each do |opportunity|
                if Time.at(opportunity.date).to_date >= start_date && Time.at(opportunity.date).to_date < end_date
                    hrs += opportunity.hours * opportunity.users.count
                end
            end
            ArchivedOpportunity.all.each do |archived|
                if Time.at(archived.date).to_date >= start_date && Time.at(archived.date).to_date < end_date
                    hrs += archived.hours
                end
            end
        else
            user.opportunities.each do |opportunity|
                if Time.at(opportunity.date).to_date >= start_date && Time.at(opportunity.date).to_date < end_date
                    hrs += opportunity.hours * opportunity.users.count
                end
            end
            user.archived_opportunities.each do |archived|
                if Time.at(archived.date).to_date >= start_date && Time.at(archived.date).to_date < end_date
                    hrs += archived.hours
                end
            end
        end
        hrs
    end
end
