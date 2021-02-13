class OrgAdmin < User
    def self.initialize_admins(institution, name, email)
        if !institution.nil?
            org = Organization.create(
              name: institution,
              approved:true
            )

            if name && email
              rand_password = ('0'..'z').to_a.shuffle.first(8).join
              new_admin = OrgAdmin.create(
                  name: name,
                  email: email,
                  admin: true,
                  password: rand_password,
                  approved: true
              )
              new_admin.save
              new_admin.organization = org
            end
            new_admin
        end
    end
end
