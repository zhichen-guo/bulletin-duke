class Interface < ApplicationRecord
    has_many :pictures, as: :imageable
    has_many :landmarks

    validates_format_of :primary_color, :secondary_color, :accent_color, :with => /\A#[a-fA-F0-9]{6}\Z/i, :message => "Hey! This doesn't work"
    validates_presence_of :institution
    has_many :o_auth_strategies

    #sets interface customizations if they were filled out
    def self.start_custom(name, tagline, institution, primary, secondary, accent, time_zone)
        interface = Interface.new
        interface.save

        if !name.blank?
            interface.name = name
        else
            interface.name = 'The Bulletin'
        end
        if !tagline.blank?
            interface.tag_line = tagline
        else
            interface.tag_line = 'An all-encompassing web platform connecting volunteers to their communities.'
        end

        if !institution.blank?
            interface.institution = institution
        else
            interface.institution = 'Duke University'
        end

        if !primary.blank?
            interface.primary_color = primary
        else
            interface.primary_color = '#132357'
        end
        if !secondary.blank?
            interface.secondary_color = secondary
        else
        interface.secondary_color = '#0577B1'
        end
        if !accent.blank?
            interface.accent_color = accent
        else
            interface.accent_color = '#B76D68'
        end

        if time_zone
            interface.time_zone = time_zone
        else
            interface.time_zone = 'Eastern Time (US & Canada)'
        end
        
        interface.save
        interface
    end

    #resizes and adds interface pictures
    def self.add_images(interface, interface_vector, interface_logo, school_logo)
        if (interface_vector)
            image = MiniMagick::Image.read(interface_vector)
            image.resize "698x459"
            vector = Picture.new(name: "#{interface.id}vec", imageable_id: interface.id, imageable_type: "#{interface.class}")
            vector.image = image
            vector.save!
            interface.pictures << vector
          end
          if (interface_logo)
            image = MiniMagick::Image.read(interface_logo)
            image.resize "161x25"
            logo = Picture.new(name: "#{interface.id}logo", imageable_id: interface.id, imageable_type: "#{interface.class}")
            logo.image = image
            logo.save!
            interface.pictures << logo
          end
          if (school_logo)
            slogo = Picture.new(name: "#{interface.id}slogo", imageable_id: interface.id, imageable_type: "#{interface.class}")
            slogo.image = school_logo
            slogo.save!
            interface.pictures << slogo
          end
    end
end
