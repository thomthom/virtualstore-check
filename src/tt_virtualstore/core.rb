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
  module TT
    if @lib2_update.nil?
      url = 'http://www.thomthom.net/software/sketchup/tt_lib2/errors/not-installed'
      options = {
        :dialog_title => 'TT_Lib² Not Installed',
        :scrollable => false, :resizable => false, :left => 200, :top => 200
      }
      w = UI::WebDialog.new( options )
      w.set_size( 500, 300 )
      w.set_url( "#{url}?plugin=#{File.basename( __FILE__ )}" )
      w.show
      @lib2_update = w
    end
  end
end


#-------------------------------------------------------------------------------

if defined?( TT::Lib ) && TT::Lib.compatible?( '2.7.0', 'VirtualStore' )

module TT::Plugins::VirtualStore
  
  
  ### MENU & TOOLBARS ### ------------------------------------------------------
  
  unless file_loaded?( __FILE__ )
    # Menus
    m = TT.menu( 'Plugins' )
    m.add_item( 'Check VirtualStore' ) { self.check_virtualstore }
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
  #   TT::Plugins::Template.reload
  #
  # @param [Boolean] tt_lib Reloads TT_Lib2 if +true+.
  #
  # @return [Integer] Number of files reloaded.
  # @since 1.0.0
  def self.reload( tt_lib = false )
    original_verbose = $VERBOSE
    $VERBOSE = nil
    TT::Lib.reload if tt_lib
    # Core file (this)
    load __FILE__
    # Supporting files
    if defined?( PATH ) && File.exist?( PATH )
      x = Dir.glob( File.join(PATH, '*.{rb,rbs}') ).each { |file|
        load file
      }
      x.length + 1
    else
      1
    end
  ensure
    $VERBOSE = original_verbose
  end

end # module

end # if TT_Lib

#-------------------------------------------------------------------------------

file_loaded( __FILE__ )

#-------------------------------------------------------------------------------