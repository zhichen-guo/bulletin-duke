class Address < ApplicationRecord
    belongs_to :locatable, polymorphic: true, optional: true
    validates_presence_of :street, :city, :state, :zip

    #formats addresses for Geocoder
    def printable_address
        [self.street, self.city, self.state, self.zip].compact.join(', ')
    end
end
