require 'date'

class Opportunity < ApplicationRecord

  validates :description, :volunteers_needed, :title, :date, :presence => true
  validates :description, :length => {:minimum => 5}
  validates :date, exclusion: { in: %w("mm/dd/yyyy") }

  has_and_belongs_to_many :tags
  belongs_to :organization
  has_many :pictures, :as => :imageable, :dependent => :delete_all
  has_and_belongs_to_many :users
  has_one :address, as: :locatable
  accepts_nested_attributes_for :address
  has_many :archived_opportunities, dependent: :destroy
  has_and_belongs_to_many :approvals
  has_many :feedbacks

  geocoded_by :location
  after_validation :geocode

  def location
      if self.address.nil?
          Interface.first.landmarks.first.address.zip
      else
          [self.address.street, self.address.city, self.address.state, self.address.zip].compact.join(', ')
      end
  end

  #converts DateTime to readable string
  def self.convert_date_string(date, time)
      temp = date + "T" + time.to_s + ":00"
      DateTime.parse(temp.in_time_zone(Interface.first.time_zone).to_s).to_time.utc.to_i
  end

  def display_date_time(date)
      temp = Time.at(date.to_i).strftime("%Y %m %d %H %M %S")
      arr = temp.split
      d = DateTime.new(arr[0].to_i, arr[1].to_i, arr[2].to_i, arr[3].to_i, arr[4].to_i, arr[5].to_i).in_time_zone(Interface.first.time_zone)
      d.strftime("%a, %b %d at %I:%M %p %Z")
  end

  def display_date(date)
      temp = Time.at(date.to_i).strftime("%Y %m %d %H %M %S")
      arr = temp.split
      d = DateTime.new(arr[0].to_i, arr[1].to_i, arr[2].to_i, arr[3].to_i, arr[4].to_i, arr[5].to_i)
      d.strftime("%Y-%m-%d")
  end

  def display_date_pretty(date)
    temp = Time.at(date.to_i).strftime("%Y %m %d %H %M %S")
    arr = temp.split
    d = DateTime.new(arr[0].to_i, arr[1].to_i, arr[2].to_i, arr[3].to_i, arr[4].to_i, arr[5].to_i)
    d.strftime("%a, %b %d")
  end
  
  def self.display_date_mailer(date)
    temp = Time.at(date.to_i).strftime("%Y %m %d %H %M %S")
     arr = temp.split
     d = DateTime.new(arr[0].to_i, arr[1].to_i, arr[2].to_i, arr[3].to_i, arr[4].to_i, arr[5].to_i)
     d.strftime("%-d %b %Y %H:%M:%S %Z")
  end

  def display_time(date)
    temp = Time.at(date.to_i).strftime("%Y %m %d %H %M %S")
    arr = temp.split
    d = DateTime.new(arr[0].to_i, arr[1].to_i, arr[2].to_i, arr[3].to_i, arr[4].to_i, arr[5].to_i).in_time_zone((Interface.first.time_zone))
    d.strftime("%H:%M")
  end

  def display_location(location)
      arr = location.split(", ")
      l = "#{arr[0]}, #{arr[1]}"
  end

  def convert_date_string(date, time)
  end

  #checks whether an opportunity is still active
  def self.update_active
    Opportunity.where(active: true).each do |opportunity|
      if opportunity.date <= Time.now.to_i && opportunity.ongoing == false
        opportunity.active = 0
        opportunity.save
      end
    end
  end

  def self.hours_this_week
    start_date = (Date.today - Date.today.wday).to_time.to_i
    end_date = Time.now.to_i
    hrs = 0
    Opportunity.all.each do |opportunity|
      if opportunity.date >= start_date && opportunity.date < end_date
        hrs += opportunity.hours * opportunity.users.count
      end
    end
    ArchivedOpportunity.all.each do |archived|
      if archived.date >= start_date && archived.date < end_date
        hrs += archived.hours
      end
    end
    hrs
  end

  def self.hours_of_week(start_date, end_date)
    hrs = 0
    Opportunity.all.each do |opportunity|
      if opportunity.date >= start_date && opportunity.date < end_date
        hrs += opportunity.hours * opportunity.users.count
      end
    end
    ArchivedOpportunity.all.each do |archived|
      if archived.date >= start_date && archived.date < end_date
        hrs += archived.hours
      end
    end
    hrs
  end

  def self.hours_this_month
    start_date = Date.today.at_beginning_of_month.to_time.to_i
    end_date = Time.now.to_i
    hrs = 0
    Opportunity.all.each do |opportunity|
      if opportunity.date >= start_date && opportunity.date < end_date
        hrs += opportunity.hours * opportunity.users.count
      end
    end
    ArchivedOpportunity.all.each do |archived|
      if archived.date >= start_date && archived.date < end_date
        hrs += archived.hours
      end
    end
    hrs
  end

  def self.hours_of_month(start_date, end_date)
    hrs = 0
    Opportunity.all.each do |opportunity|
      if opportunity.date >= start_date && opportunity.date < end_date
        hrs += opportunity.hours * opportunity.users.count
      end
    end
    ArchivedOpportunity.all.each do |archived|
      if archived.date >= start_date && archived.date < end_date
        hrs += archived.hours
      end
    end
    hrs
  end

  def self.hours_of_month_where(start_date, end_date, tag)
    hrs = 0
    Opportunity.joins(:tags).where(tags: { name: tag}).each do |opportunity|
      if opportunity.date >= start_date && opportunity.date < end_date
        hrs += opportunity.hours * opportunity.users.count
        hrs += opportunity.archived_opportunities.all.pluck(:hours).sum
      end
    end
    hrs
  end

  # def self.filter_by_distance(current_location, distance_limit)
  #     if current_location == "west"
  #         current_location = [36.000933, -78.938221]
  #     elsif current_location == "east"
  #         current_location = [36.005995, -78.914716]
  #     elsif current_location == "swift"
  #         current_location = [36.002677, -78.921668]
  #     end
  #     Opportunity.near(current_location, distance_limit, :units => :mi)
  # end

  def distance_from(location: Geocoder.coordinates(Landmark.first.address.printable_address))
    opp_coords = Geocoder.coordinates(address.printable_address)
    Geocoder::Calculations.distance_between(location, opp_coords).round(1)
  end

  def self.filter_by_frequency(ongoing)
      if ongoing == "ongoing"
          Opportunity.where(ongoing: true)
      else
          Opportunity.where(ongoing: false)
      end
  end

  def self.filter_by_remote(remote)
      if remote == "remote"
          Opportunity.where(remote: true)
      else
          Opportunity.where(remote: false)
      end
  end

  # def self.filter_by_approved
  #   Opportunity.where(organization.approved: true)
  # end

  def self.filter_by_tags(arr)
    opportunities = Opportunity.none
    arr.each do |tag|
        opportunities = opportunities.or(Opportunity.joins(:tags).where(tags: { name: tag}))
    end
    opportunities
  end

  def self.filter_by_distance(current_location, distance_limit)
      if current_location == "loc1"
          current_location = Geocoder.coordinates(Landmark.first.address.printable_address)
      elsif current_location == "loc2"
          current_location = Geocoder.coordinates(Landmark.second.address.printable_address)
      elsif current_location == "loc3"
          current_location = Geocoder.coordinates(Landmark.third.address.printable_address)
      end
      Opportunity.near(current_location, distance_limit, :units => :mi)
    end

  def self.update_likes
    Opportunity.where(active: true).each do |opportunity|
      opportunity.likes = opportunity.organization.ratings.count
      opportunity.save
    end
  end

  def self.org_opps(user)
    Opportunity.where(organization_id: user.organization_id)
  end

  def self.weekly_stats(today)
    stats = Hash.new
    for i in 0..7
      date = today - today.wday + (7 * (i - 7))
      stats[date.strftime("%b %d") + " - " + (date + 6).strftime("%b %d")] =
        Opportunity.hours_of_week(date.to_time.to_i, (date + 7).to_time.to_i)
    end
    stats
  end

  def self.monthly_stats(today)
    stats = Hash.new
    for i in 0..11
        date = 1.year.ago.at_beginning_of_month.to_time + i.month
        stats[date.strftime("%b")] =
            Opportunity.hours_of_month(date.to_time.to_i, (date + 1.month).to_time.to_i)
    end
    stats
  end

  def self.opp_tags(today)
    week = Hash.new
    month = Hash.new
    year = Hash.new
    Tag.all.reverse.each do |tag|
        week[tag.name] = Opportunity.hours_of_month_where(
            (today - today.wday).to_time.to_i, today.to_time.to_i, tag.name)
        month[tag.name] = Opportunity.hours_of_month_where(
            today.at_beginning_of_month.to_time.to_i, today.to_time.to_i, tag.name)
        year[tag.name] = Opportunity.hours_of_month_where(
            today.beginning_of_year.to_time.to_i, today.to_time.to_i, tag.name)
    end
    [week, month, year]
  end

  def self.opp_trends(today, monthly_stats)
    trends = Hash.new
    percents = Hash.new
    Tag.all.each do |tag|
        monthly_tag = Hash.new
        monthly_tag_percs = Hash.new
        for i in 0..11
            date = 1.year.ago.at_beginning_of_month.to_time + i.month
            month_hours = Opportunity.hours_of_month_where(date.to_time.to_i, (date + 1.month).to_time.to_i, tag.name)
            date_key = date.strftime("%b")
            monthly_tag[date_key] = month_hours
            if monthly_stats[date_key] != 0
                monthly_tag_percs[date_key] = month_hours * 100 / monthly_stats[date_key]
            else
                monthly_tag_percs[date_key] = 0
            end
        end
        trends[tag.name] = monthly_tag
        percents[tag.name] = monthly_tag_percs
    end
    [trends, percents]
  end

  def self.sorting_opps(upcoming, highrated, freq, remo, distance, loc, tags, is_admin, user)

    Opportunity.update_active

    if is_admin
      opps = Opportunity.all.org_opps(user)
    else
      opps = Opportunity.all.where(active: true)
    end

    if !freq.nil?
      opps = opps.filter_by_frequency(freq)
    end

    if !remo.nil?
      opps = opps.filter_by_remote(remo)
    end

    if !distance.nil?
      loc = Landmark.first.address.printable_address if loc.nil?
      noloc = opps.where(location: nil)
      opps = opps.filter_by_distance(loc, distance.to_i)
      arr = noloc + opps
      opps = Opportunity.where(id: arr.map(&:id))
    end

    opps = opps.filter_by_tags(tags) if !tags.nil?

    if highrated
      Opportunity.update_likes
    end

    if !upcoming && !highrated
      opps = opps.reorder(featured: :desc, created_at: :desc)
    elsif !upcoming && highrated
      opps = opps.reorder(likes: :desc, created_at: :desc)
    elsif upcoming && !highrated
      opps = opps.reorder(:date, created_at: :desc)
    elsif !page
      opps = opps.reorder(:date, likes: :desc, created_at: :desc)
    end

    opps

  end
end
