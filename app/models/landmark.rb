class Landmark < ApplicationRecord
    has_one :address, as: :locatable
    belongs_to :interface

    #creates interface's landmarks and corresponding addresses
    def self.generate_landmarks(interface, lm1, add1, lm2, add2, lm3, add3)
        if !lm1.blank? && !add1.blank?
            landmark1 = Landmark.create(name: lm1)
            address1 = Address.create(street: add1[:street1], city: add1[:city1],
              state: add1[:state1], zip: add1[:zip1])

            interface.landmarks << landmark1
            landmark1.address = address1
        else
            landmark1 = Landmark.create(name: "Duke West Campus")
            address1 = Address.create(street: "Few Quadrangle", city: "Durham", state: "North Carolina", zip: 27710)
            interface.landmarks << landmark1
            landmark1.address = address1
        end

        if !lm2.blank? && !add2.blank?
            landmark2 = Landmark.create(name: lm2)
            address2 = Address.create(street: add2[:street2], city: add2[:city2],
              state: add2[:state2], zip: add2[:zip2])

            interface.landmarks << landmark2
            landmark2.address = address2
        end
        if !lm3.blank? && !add3.blank?
            landmark3 = Landmark.create(name: lm3)
            address3 = Address.create(street: add3[:street3], city: add3[:city3],
              state: add3[:state3], zip: add3[:zip3])

            interface.landmarks << landmark3
            landmark3.address = address3
        end
    end
end
