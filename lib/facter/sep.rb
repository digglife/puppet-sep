KEY64 = 0x100
KEY32 = 0x200
KEY_READ = 0x20019

def key_exists?(path, key)
  begin
      Win32::Registry::HKEY_LOCAL_MACHINE.open(path, KEY_READ | KEY64) do |reg|
        !!reg.read(key)
      end
  rescue
      false
  end
end

def is_sep_installed?
  Win32::Service.exists?('SepMasterService')
end

def sep_status

  return nil unless is_sep_installed?
  
  sep_path = 'SOFTWARE\Symantec\Symantec Endpoint Protection'
  status = {}

  status['managed'] = key_exists?(sep_path + '\SMC\SYLINK\SyLink', "HostGUID")
  
  hklm = Win32::Registry::HKEY_LOCAL_MACHINE
  hklm.open(sep_path + '\currentversion\public-opstate', KEY_READ | KEY64) do |reg|
    if reg['avrunningstatus'] == 1
      status['running'] = true
    else 
      status['running'] = false
    end

    definition_key = key_exists?(sep_path + '\currentversion\public-opstate', 'LatestVirusDefsDate')
    status['definition'] = definition_key ? reg['LatestVirusDefsDate'] : nil
    
    if status['managed']
      status['sepm'] = reg['LastServerIP']
    else
      status['sepm'] = nil
    end
  end
  
  hklm.open(sep_path + '\currentversion', KEY_READ) do |reg|
    status['version'] = reg['PRODUCTVERSION']
  end

  hklm.open(sep_path + '\SMC', KEY_READ) do |reg|
    status['path'] = reg['smc_install_path']
  end

  if status['managed']
    hklm.open(sep_path + '\SMC\SYLINK\SyLink', KEY_READ | KEY64) do |reg|
      status['online'] = ( reg['PolicyMode'] == 1 ) ? true : false
    end
  else
    status['online'] = false
  end

  status
end

Facter.add :sep do
  confine :kernel => :linux
  setcode do
    nil
  end
end


Facter.add :sep do
  confine :kernel => :windows
  setcode do
    require 'win32/registry'
    require 'win32/service'
    sep_status()
  end
end