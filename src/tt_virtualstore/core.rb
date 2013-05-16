#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
begin
  require 'TT_Lib2/core.rb'
rescue LoadError => e
  timer = UI.start_timer( 0, false ) {
    UI.stop_timer( timer )
    filename = File.basename( __FILE__ )
    message = "#{filename} require TT_Lib² to be installed.\n"
    message << "\n"
    message << "Would you like to open a webpage where you can download TT_Lib²?"
    result = UI.messagebox( message, MB_YESNO )
    if result == 6 # YES
      UI.openURL( 'http://www.thomthom.net/software/tt_lib2/' )
    end
  }
end


#-------------------------------------------------------------------------------

if defined?( TT::Lib ) && TT::Lib.compatible?( '2.6.0', 'VirtualStore' )

module TT::Plugins::VirtualStore
  
  
  ### CONSTANTS ### ------------------------------------------------------------
  
  # Plugin information
  PLUGIN_ID       = 'TT_VirtualStore'.freeze
  PLUGIN_NAME     = 'VirtualStore'.freeze
  PLUGIN_VERSION  = TT::Version.new(1,0,0).freeze
  
  # Version information
  RELEASE_DATE    = '10 Oct 12'.freeze
  
  
  ### MENU & TOOLBARS ### ------------------------------------------------------
  
  unless file_loaded?( __FILE__ )
    # Menus
    m = TT.menu( 'Plugins' )
    m.add_item( 'Check VirtualStore' ) { self.check_virtualstore }
  end 
  
  
  ### LIB FREDO UPDATER ### ----------------------------------------------------
  
  def self.register_plugin_for_LibFredo6
    {   
      :name => PLUGIN_NAME,
      :author => 'thomthom',
      :version => PLUGIN_VERSION.to_s,
      :date => RELEASE_DATE,   
      :description => 'Opens the VirtualStore folder for the Plugins folder.',
      :link_info => 'http://sketchucation.com/forums/viewtopic.php?f=180&t=48399'
    }
  end
  
  
  ### MAIN SCRIPT ### ----------------------------------------------------------
  
  # @return [String]
  # @since 1.0.0
  def self.check_virtualstore
    plugins_folder = Sketchup.find_support_file( 'Plugins' )
    virtual_folder = self.get_virtual_path( plugins_folder )
    puts virtual_folder
    if File.exist?( virtual_folder )
      UI.openURL( virtual_folder )
    else
      UI.messagebox( 'No files in VirtualStore.' )
    end
  end


  # @return [String]
  # @since 1.0.0
  def self.is_virtualized?( file )
    virtualfile = self.get_virtual_path( file )
    File.exist?( virtualfile )
  end
  
  
  # @return [String]
  # @since 1.0.0
  def self.get_virtual_path( file )
    # (!) Windows check.
    filename = File.basename( file )
    filepath = File.dirname( file )
    # Verify file exists.
    unless File.exist?( file )
      raise IOError, "The file '#{file}' does not exist."
    end
    # See if it can be found in virtual store.
    virtualstore = File.join( ENV['LOCALAPPDATA'], 'VirtualStore' )
    path = filepath.split(':')[1]
    File.join( virtualstore, path, filename )
  end

  
  ### DEBUG ### ----------------------------------------------------------------
  
  # @note Debug method to reload the plugin.
  #
  # @example
  #   TT::Plugins::VirtualStore.reload
  #
  # @param [Boolean] tt_lib
  #
  # @return [Integer]
  # @since 1.0.0
  def self.reload( tt_lib = false )
    original_verbose = $VERBOSE
    $VERBOSE = nil
    TT::Lib.reload if tt_lib
    # Core file (this)
    load __FILE__
    # Supporting files
    #x = Dir.glob( File.join(PATH, '*.{rb,rbs}') ).each { |file|
    #  load file
    #}
    #x.length
  ensure
    $VERBOSE = original_verbose
  end

end # module TT::Plugins::VirtualStore

end # if TT_Lib

#-------------------------------------------------------------------------------

file_loaded( __FILE__ )

#-------------------------------------------------------------------------------