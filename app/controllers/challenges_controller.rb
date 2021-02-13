class ChallengesController < ApplicationController

    before_action :check_auth

    def index
    end

    def show
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @challenge = Challenge.find(params[:id])
    end

    def new
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @challenge = Challenge.new
    end

    def create
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @challenge = Challenge.new(challenges_params)

        # setting challenge type from radios
        if params[:user]
            @challenge.challenge_type = true
        else
            @challenge.challenge_type = false
        end

        if @challenge.save
            redirect_to '/admin_home'
        else
            render 'new'
        end
    end

    def edit
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @challenge = Challenge.find(params[:id])
    end

    def update
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @challenge = Challenge.find(params[:id])

        if(@challenge.update(challenges_params))
            redirect_to '/admin_home'
        else
            render 'edit'
        end
    end

    def destroy
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @challenge = Challenge.find(params[:id])
        @challenge.destroy
        redirect_to '/admin_home'
    end

    private def challenges_params
        if Interface.first.nil?
            redirect_to root_url and return
        end

        params.require(:challenge).permit(:title, :description, :goal, :start, :end)
    end
end