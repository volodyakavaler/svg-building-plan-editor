module SidebarHelper
  def side_bar_items
    result = []

    result << {
      :name => t('sidebar.users'),
      :icon => 'users',
      :controller => :users,
      :action => :index
    }
    result << {
      :name => t('sidebar.profile'),
      :icon => 'user',
      :controller => :welcome,
      :action => :index
    }
    result << {
      :name => t('sidebar.plans'),
      :icon => 'map',
      :controller => :campuses,
      :action => :index
    }
    result << {
      :name => t('sidebar.roomtypes'),
      :icon => 'cog',
      :controller => :roomtypes,
      :action => :index
    }
    result << {
      :name => t('sidebar.search'),
      :icon => 'search',
      :controller => :rooms,
      :action => :search
    }
    # result << {
    #   :name => t('sidebar.buildings'),
    #   :icon => 'home',
    #   :controller => :buildings,
    #   :action => :index
    # }

    result
  end

  def is_open?(ctr)
    ctr.to_s == controller_name.to_s
  end
end
