########################################################################
# Please notice that this script is for MoDIS on VS2008 (VC9)
# NOT suitable for MoDIS on VC6
# 20251214 for VS2022
# 20251215 fail path
########################################################################

package createMoDIS;
use strict;
use DirHandle;
use File::Basename;
use File::Copy;
use File::Path;
use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);
@ISA = qw(Exporter);
@EXPORT = qw(CheckIfFolder CopyFolder CopyFile);
@EXPORT_OK = qw(CheckIfFolder CopyFolder CopyFile);

#######################################################################################################################
#######################################################################################################################
#######################################################################################################################

sub create_vcproj_header
{
	my $lib_GUID = shift;
	my $lib = shift;
	my $result = <<__STRING__
<?xml version=\"1.0\" encoding=\"utf-8\"?>
<Project DefaultTargets=\"Build\" xmlns=\"http://schemas.microsoft.com/developer/msbuild/2003\">
  <ItemGroup Label=\"ProjectConfigurations\">
    <ProjectConfiguration Include=\"Debug|Win32\">
      <Configuration>Debug</Configuration>
      <Platform>Win32</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include=\"Release|Win32\">
      <Configuration>Release</Configuration>
      <Platform>Win32</Platform>
    </ProjectConfiguration>
  </ItemGroup>
  <PropertyGroup Label=\"Globals\">
    <VCProjectVersion>17.0</VCProjectVersion>
    <Keyword>Win32Proj</Keyword>
    <ProjectGuid>{$lib_GUID}</ProjectGuid>
    <RootNamespace>MoDIS</RootNamespace>
    <WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>
  </PropertyGroup>
  <Import Project=\"\$\(VCTargetsPath)\\Microsoft.Cpp.Default.props\" />
__STRING__
;
	return $result;
}

sub create_vcproj_foot
{
	return <<__STRING__
  <Import Project=\"\$\(VCTargetsPath)\\Microsoft.Cpp.targets\" />
  <ImportGroup Label=\"ExtensionTargets\">
  </ImportGroup>
</Project>
__STRING__
;
}
#######################################################################################################################
#######################################################################################################################
#######################################################################################################################

sub create_vcproj_configuration
{
	my $lib = shift;
	my $compile_option = shift;
	my $include_path = shift;
	my $mmi_version = shift;
	my $modis_suffix = shift;

	#my $option_set = "";
	my $incl_set = "";

	foreach my $option (split("\n", $include_path))
	{
		$option = short_path($option);
		#$option_set .= "$option\n";
		$option =~ /\/I\s\"(.*)\"/;
		$option = $1;
		$incl_set .="\"$option\";";
	}

	my $option_in_ini = ""; # these options will be written into vcproj file
	foreach my $option2 (split("\n", $compile_option))
	{
		$option2 =~ /\"(.*)\"/;
		$option_in_ini .= "$1;";
	}

#	if ($lib =~ /modis_ui_mslt|modis_ui_all/i)
#	{
#		open H,">MoDIS_UI/$lib.ini";
#		print H $option_set;
#		close H;
#	}
#	else
#	{
#		open H,">$lib/${lib}${modis_suffix}.ini";
#		print H $option_set;
#		close H;
#	}

#	my $lib_ini = $lib . $modis_suffix . ".ini";


	my $result = <<__STRING__
  <PropertyGroup Condition=\"'\$\(Configuration)|\$\(Platform)'=='Release|Win32'\" Label=\"Configuration\">
    <ConfigurationType>StaticLibrary</ConfigurationType>
    <PlatformToolset>v143</PlatformToolset>
    <UseOfMfc>false</UseOfMfc>
    <CharacterSet>MultiByte</CharacterSet>
  </PropertyGroup>
  <PropertyGroup Condition=\"'\$\(Configuration)|\$\(Platform)'=='Debug|Win32'\" Label=\"Configuration\">
    <ConfigurationType>StaticLibrary</ConfigurationType>
    <PlatformToolset>v143</PlatformToolset>
    <UseOfMfc>false</UseOfMfc>
    <CharacterSet>MultiByte</CharacterSet>
  </PropertyGroup>
  <Import Project=\"\$\(VCTargetsPath)\\Microsoft.Cpp.props\" />
  <ImportGroup Label=\"ExtensionSettings\">
  </ImportGroup>
  <ImportGroup Label=\"Shared\">
  </ImportGroup>
  <ImportGroup Label=\"PropertySheets\" Condition=\"'\$\(Configuration)|\$\(Platform)'=='Debug|Win32'\">
    <Import Project=\"\$\(UserRootDir)\\Microsoft.Cpp.\$\(Platform).user.props\" Condition=\"exists('\$\(UserRootDir)\\Microsoft.Cpp.\$\(Platform).user.props')\" Label=\"LocalAppDataPlatform\" />
  </ImportGroup>
  <ImportGroup Label=\"PropertySheets\" Condition=\"'\$\(Configuration)|\$\(Platform)'=='Release|Win32'\">
    <Import Project=\"\$\(UserRootDir)\\Microsoft.Cpp.\$\(Platform).user.props\" Condition=\"exists('\$\(UserRootDir)\\Microsoft.Cpp.\$\(Platform).user.props')\" Label=\"LocalAppDataPlatform\" />
  </ImportGroup>
  <PropertyGroup Label=\"UserMacros\" />
  <PropertyGroup Condition=\"'\$\(Configuration)|\$\(Platform)'=='Debug|Win32'\">
    <OutDir>.\\Debug${modis_suffix}\\</OutDir>
    <IntDir>.\\Debug${modis_suffix}\\</IntDir>
    <LinkIncremental>true</LinkIncremental>
  </PropertyGroup>
  <PropertyGroup Condition=\"'\$\(Configuration)|\$\(Platform)'=='Release|Win32'\">
    <OutDir>.\\Release${modis_suffix}\\</OutDir>
    <IntDir>.\\Release${modis_suffix}\\</IntDir>
    <LinkIncremental>false</LinkIncremental>
  </PropertyGroup>
  <ItemDefinitionGroup Condition=\"'\$\(Configuration)|\$\(Platform)'=='Debug|Win32'\">
    <ClCompile>
      <AdditionalOptions>/MP /J %(AdditionalOptions)</AdditionalOptions>
      <Optimization>Disabled</Optimization>
      <PreprocessorDefinitions>WIN32;_DEBUG;_CONSOLE;_CRT_SECURE_NO_WARNINGS;$option_in_ini;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <MinimalRebuild>false</MinimalRebuild>
      <RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>
      <PrecompiledHeaderOutputFile>.\Debug${modis_suffix}\\$lib.pch</PrecompiledHeaderOutputFile>
      <AssemblerListingLocation>.\Debug${modis_suffix}\\</AssemblerListingLocation>
      <ObjectFileName>.\\Debug${modis_suffix}\\</ObjectFileName>
      <ProgramDataBaseFileName>.\\Debug${modis_suffix}\\</ProgramDataBaseFileName>
      <BrowseInformation>true</BrowseInformation>
      <WarningLevel>Level3</WarningLevel>
      <SuppressStartupBanner>true</SuppressStartupBanner>
      <DebugInformationFormat>ProgramDatabase</DebugInformationFormat>
      <ForcedIncludeFiles>auto_header.h;%(ForcedIncludeFiles)</ForcedIncludeFiles>
      <DisableSpecificWarnings>4996;%(DisableSpecificWarnings)</DisableSpecificWarnings>
      <AdditionalIncludeDirectories>$incl_set;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
    </ClCompile>
    <Link>
      <OutputFile>.\\Debug${modis_suffix}\\$lib.lib</OutputFile>
      <SuppressStartupBanner>true</SuppressStartupBanner>
      <UACExecutionLevel>RequireAdministrator</UACExecutionLevel>
      <GenerateDebugInformation>true</GenerateDebugInformation>
      <ProgramDatabaseFile>.\\Debug${modis_suffix}\\$lib.pdb</ProgramDatabaseFile>
      <GenerateMapFile>true</GenerateMapFile>
      <MapFileName>.\\Debug${modis_suffix}\\$lib.map</MapFileName>
      <SubSystem>Console</SubSystem>
      <RandomizedBaseAddress>false</RandomizedBaseAddress>
      <DataExecutionPrevention />
      <TargetMachine>MachineX86</TargetMachine>
    </Link>
  </ItemDefinitionGroup>
  <ItemDefinitionGroup Condition=\"'\$\(Configuration)|\$\(Platform)'=='Release|Win32'\">
    <ClCompile>
      <AdditionalOptions>/MP /J %(AdditionalOptions)</AdditionalOptions>
      <Optimization>Disabled</Optimization>
      <PreprocessorDefinitions>WIN32;NDEBUG;_CONSOLE;_CRT_SECURE_NO_WARNINGS;$option_in_ini;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <MinimalRebuild>false</MinimalRebuild>
      <RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>
      <BufferSecurityCheck>false</BufferSecurityCheck>
      <PrecompiledHeaderOutputFile>.\\Release${modis_suffix}\\$lib.pch</PrecompiledHeaderOutputFile>
      <AssemblerListingLocation>.\\Release${modis_suffix}\\</AssemblerListingLocation>
      <ObjectFileName>.\\Release${modis_suffix}\\</ObjectFileName>
      <ProgramDataBaseFileName>.\\Release${modis_suffix}\\</ProgramDataBaseFileName>
      <WarningLevel>Level3</WarningLevel>
      <SuppressStartupBanner>true</SuppressStartupBanner>
      <DebugInformationFormat>ProgramDatabase</DebugInformationFormat>
      <ForcedIncludeFiles>auto_header.h;%(ForcedIncludeFiles)</ForcedIncludeFiles>
      <DisableSpecificWarnings>4996;%(DisableSpecificWarnings)</DisableSpecificWarnings>
      <AdditionalIncludeDirectories>$incl_set;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
    </ClCompile>
    <Link>
      <OutputFile>.\\Release${modis_suffix}\\$lib.lib</OutputFile>
      <SuppressStartupBanner>true</SuppressStartupBanner>
      <UACExecutionLevel>RequireAdministrator</UACExecutionLevel>
      <ProgramDatabaseFile>.\\Release${modis_suffix}\\$lib.pdb</ProgramDatabaseFile>
      <SubSystem>Console</SubSystem>
      <RandomizedBaseAddress>false</RandomizedBaseAddress>
      <DataExecutionPrevention />
      <TargetMachine>MachineX86</TargetMachine>
    </Link>
  </ItemDefinitionGroup>
__STRING__
;
	return $result;
}
#######################################################################################################################
#======================================================================================================================
my %file_list_table;
my %added_file_list_table;
my $added_file_list_table_cnt;

sub output_Source_File
{
	my $lib = shift;
	my $fullpath = shift;
	my $node = shift;
	my $WIN32_COMPILE_OPTION = shift;
	my $PreprocessorDefs ="";
	my $result = "";
	if(defined($$WIN32_COMPILE_OPTION{lc("$fullpath\\$node")}))
	{
		$PreprocessorDefs .= $$WIN32_COMPILE_OPTION{lc("$fullpath\\$node")};
	}
	elsif(defined($$WIN32_COMPILE_OPTION{lc($node)}))
	{
		$PreprocessorDefs .= $$WIN32_COMPILE_OPTION{lc($node)};
	}

	if ($node =~ /(\.c)|(\.cpp)$/)
	{
		$result .= "    <ClCompile Include=\"$fullpath\\$node\"/>\n"
	}
	return $result;
}

sub create_filter_tree
{
	my $level = shift;
	my $lib = shift;
	my $fullpath = shift;
	my $path = shift;
	my $WIN32_COMPILE_OPTION = shift;

	my $dir = new DirHandle();
	my $result = "";

	$level++;

	opendir $dir,"$lib/$fullpath";
	foreach my $node (sort readdir($dir))
	{
		next if($node eq '.');
		next if($node eq '..');
		if (CheckIfFolder("$lib/$fullpath/$node"))
		{
			my $file_counter = $added_file_list_table_cnt;
			my $content = create_filter_tree($level,$lib,"$fullpath\\$node",$node,$WIN32_COMPILE_OPTION);
			$result .= $content if($file_counter < $added_file_list_table_cnt);
		}
		else
		{
			next if(($file_list_table{lc("$fullpath\\$node")} != 1));
			next if($node =~ /\.c$/ && !defined($file_list_table{lc("$fullpath\\$node")}));
			next if($node =~ /\.cpp$/ && !defined($file_list_table{lc("$fullpath\\$node")}));
			next if(defined($added_file_list_table{lc("$fullpath\\$node")}));
			if($node =~ /\.h$/i
			|| $node =~ /\.hpp$/i
			|| $node =~ /\.c$/i
			|| $node =~ /\.cpp$/i
			|| $node =~ /\.asm$/i
			|| $node =~ /\.txt$/i
			|| $node =~ /\.bat$/i)
			{
				$added_file_list_table{lc("$fullpath\\$node")} = 1;
				$result .= output_Source_File($lib, $fullpath,$node,$WIN32_COMPILE_OPTION);
				$added_file_list_table_cnt ++;
			}
		}
	}
    closedir $dir;

	$level--;
	return $result;
}

sub create_Files_List
{
	my $lib = shift;
	my $file_list = lc(shift);
	my $WIN32_COMPILE_OPTION = shift;
	my $par_lib = shift;

	my $list_set = "";
	my @unsort;

	undef %file_list_table;
	undef %added_file_list_table;
	$added_file_list_table_cnt=0;

	foreach my $file (split("\n",$file_list))
	{
		$file = short_path($file);
		$file_list_table{lc($file)} = 1;
	}

	$list_set .= "  <ItemGroup>\n";

	foreach my $file (sort keys %file_list_table)
	{
		warn "[Warning] $lib => $file does NOT exist!\n" if (! -e "$lib/$file");
		next if(defined($added_file_list_table{lc($file)}));

		if($file =~ /^(.*?\\$lib)\\/i)
		{
			my $root = $1;
			$list_set .= create_filter_tree(0,$lib,$root,$lib,$WIN32_COMPILE_OPTION);
		}
		else
		{
			push @unsort,$file;
		}
	}

	foreach my $file (sort @unsort)
	{
		$list_set .= output_Source_File($lib, dirname($file),basename($file),$WIN32_COMPILE_OPTION);
	}
	$list_set .= "  </ItemGroup>\n";
	return $list_set;
}

#======================================================================================================================
#######################################################################################################################
#######################################################################################################################
#######################################################################################################################

sub create_lib_vcproj
{
	my $lib_GUID = shift;
	my $lib = shift;
	my $vcproj_filename = shift;
	my $compile_option = shift;
	my $include_path = shift;
	my $file_list = shift;
	my $mmi_version = shift;
	my $par_lib = shift;
	my $WIN32_COMPILE_OPTION = shift;

	my $result = '';
	my $modis_suffix = '';
	if ($vcproj_filename =~ /uesim\.vcxproj/i)
	{
		$modis_suffix = '_uesim';
	}
	$result .= create_vcproj_header($lib_GUID,$lib);
	$result .= create_vcproj_configuration($lib,$compile_option,$include_path,$mmi_version,$modis_suffix);
	$result .= create_Files_List($lib,$file_list,$WIN32_COMPILE_OPTION,$par_lib);
	$result .= create_vcproj_foot();
	#$result = checkVcprojFile($result); //do not validation
	my $result_last;
	if ((-e $vcproj_filename) && (open F,"<$vcproj_filename"))
	{
		my $saved_sep = $/;
		undef $/;
		$result_last = <F>;
		$/ = $saved_sep;
		close F;
	}
	if ($result ne $result_last)
	{
		print "Write $vcproj_filename\n";
		open F, ">$vcproj_filename" or die "Fail to write $vcproj_filename";
		print F $result;
		close F;
	}
	else
	{
		print "No need to update $vcproj_filename\n";
	}
}

#######################################################################################################################
#######################################################################################################################
#######################################################################################################################
sub create_solution_header
{
	my $modis_GUID = shift;
	my $solution_filename = shift;
	my $vcproj_filename = $solution_filename;
	$vcproj_filename =~ s/\.sln$/.vcxproj/i;
	return <<__STRING__
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
Project("{$modis_GUID}") = "MoDIS", "MoDIS\\$vcproj_filename", "{$modis_GUID}"
__STRING__
;
}

sub create_solution_dependency
{
	my $lib_list = shift;
	my $lib_GUID_list = shift;
	my $modis_suffix = shift;

	my $result = "	ProjectSection(ProjectDependencies) = postProject\n";
	foreach my $lib(@$lib_list)
	{
		my $lib_GUID = $lib_GUID_list->{$lib};
		$result .= "	{$lib_GUID} = {$lib_GUID}\n"
	}
	$result .= "	EndProjectSection\nEndProject\n";
	foreach my $lib(@$lib_list)
	{
		my $lib_GUID = $lib_GUID_list->{$lib};
		$result .= "Project(\"{$lib_GUID}\") = \"$lib\", \"$lib\\${lib}${modis_suffix}.vcxproj\", \"{$lib_GUID}\"\nEndProject\n";
	}
	return $result;
}

sub create_solution_projectConfigurationPlatforms
{
	my $modis_GUID = shift;
	my $lib_list = shift;
	my $lib_GUID_list = shift;
	my $result = '';
	$result .= "	GlobalSection(ProjectConfigurationPlatforms) = postSolution\n";
	$result .= "		{$modis_GUID}.Debug|Win32.ActiveCfg = Debug|Win32\n";
	$result .= "		{$modis_GUID}.Debug|Win32.Build.0 = Debug|Win32\n";
	$result .= "		{$modis_GUID}.Release|Win32.ActiveCfg = Release|Win32\n";
	$result .= "		{$modis_GUID}.Release|Win32.Build.0 = Release|Win32\n";
	foreach my $lib(@$lib_list)
	{
		my $lib_GUID = $lib_GUID_list->{$lib};
		$result .= "		{$lib_GUID}.Debug|Win32.ActiveCfg = Debug|Win32\n";
		$result .= "		{$lib_GUID}.Debug|Win32.Build.0 = Debug|Win32\n";
		$result .= "		{$lib_GUID}.Release|Win32.ActiveCfg = Release|Win32\n";
		$result .= "		{$lib_GUID}.Release|Win32.Build.0 = Release|Win32\n";
	}
	$result .= "	EndGlobalSection\n";
	return $result;
}

sub create_solution_Global_header
{
	return <<__STRING__
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Win32 = Debug|Win32
		Release|Win32 = Release|Win32
	EndGlobalSection
__STRING__
;
}

sub create_solution_Global_foot
{
	return <<__STRING__
	GlobalSection(SolutionProperties) = preSolution
		HideSolutionNode = FALSE
	EndGlobalSection
EndGlobal
__STRING__
;
}

sub create_solution
{
	my $modis_GUID = shift;
	my $solution_filename = shift;
	my $lib_list = shift;
	my $lib_GUID = shift;

	my $modis_suffix = '';
	if ($solution_filename =~ /uesim/i)
	{
		$modis_suffix = '_uesim';
	}
	my $result = '';
	$result .= create_solution_header($modis_GUID, $solution_filename);
	$result .= create_solution_dependency($lib_list, $lib_GUID, $modis_suffix);
	$result .= create_solution_Global_header();
	$result .= create_solution_projectConfigurationPlatforms($modis_GUID, $lib_list, $lib_GUID);
	$result .= create_solution_Global_foot();

	print "Write $solution_filename\n";
	open F, ">$solution_filename" or die "Fail to write $solution_filename";
	print F $result;
	close F;
}

sub create_main_lib_vcproj
{
	my $lib_GUID = shift;
	my $modis_uesim = shift;
	my $compile_option = shift;
	my $include_path = shift;
	my $file_list = shift;
	my $mmi_version = shift;
	my $modis_mode = shift;
	my $lib_list = shift;
	my $WIN32_COMPILE_OPTION = shift;

	my $result = '';
	my $modis_suffix = '';
	if ($modis_uesim =~ /uesim/i)
	{
		$modis_suffix = '_uesim';
	}
	my $lib = $modis_uesim;
	my $vcproj_filename = "MoDIS/$lib.vcxproj";
	print "Write $vcproj_filename\n";
	$result .= create_vcproj_header($lib_GUID,$lib);
	$result .= create_main_vcproj_configuration($lib,$lib_list,$compile_option,$include_path,$mmi_version,$modis_suffix,$modis_mode);
	$result .= create_main_Files_List($lib,$file_list,$WIN32_COMPILE_OPTION,$lib_list);
	$result .= create_vcproj_foot();

	open F, ">$vcproj_filename" or die "Fail to write $vcproj_filename";
	print F $result;
	close F;
}

sub create_main_vcproj_configuration
{
	my $lib = shift;
	my $lib_list = shift;
	my $compile_option = shift;
	my $include_path = shift;
	my $mmi_version = shift;
	my $modis_suffix = shift;
	my $modis_mode = shift;

	#my $option_set = "";
	my $incl_set = "";
	my $linker_inp = "";

	foreach my $file (@$lib_list)
	{
		$file = short_path($file);
		$linker_inp .= "$file;";
	}
	
	foreach my $option (split("\n", $include_path))
	{
		$option = short_path($option);
		#$option_set .= "$option\n";
		$option =~ /\/I\s\"(.*)\"/;
		$option = $1;
		$incl_set .="\"$option\";";
	}

	my $option_in_ini = ""; # these options will be written into vcproj file
	foreach my $option2 (split("\n", $compile_option))
	{
		$option2 =~ /\"(.*)\"/;
		$option_in_ini .= "$1;";
	}

	#my $lib_ini = $lib . ".ini";
	#open H,">MoDIS/${lib}.ini";
	#print H $option_set;
	#close H;

	my $lib_dep_debug = '';
	my $lib_dep_release = '';
	if (($mmi_version ne "EMPTY_MMI") && ($mmi_version ne "EXTERNAL_MMI")) {
		$lib_dep_debug = "Debug\\MoDis_UI.lib";
		$lib_dep_release = "Release\\MoDis_UI.lib";
	} else {
		# Do not link MoDis_UI.lib when MMI_VERSION is EMPTY_MMI or EXTERNAL_MMI.
	}
	my $ignoreDefaultLib_debug;
	if (lc($modis_mode) eq "debug") {
		$ignoreDefaultLib_debug = "libc.lib;libcp.lib;libcd.lib;libcmt.lib;msvcrt.lib";
	} else {
		$ignoreDefaultLib_debug = "libc.lib;libcp.lib;libcd.lib;libcmt.lib";
	}

	my $result = <<__STRING__
  <PropertyGroup Condition=\"'\$\(Configuration)|\$\(Platform)'=='Release|Win32'\" Label=\"Configuration\">
    <ConfigurationType>Application</ConfigurationType>
    <PlatformToolset>v143</PlatformToolset>
    <UseOfMfc>false</UseOfMfc>
    <CharacterSet>MultiByte</CharacterSet>
  </PropertyGroup>
  <PropertyGroup Condition=\"'\$\(Configuration)|\$\(Platform)'=='Debug|Win32'\" Label=\"Configuration\">
    <ConfigurationType>Application</ConfigurationType>
    <PlatformToolset>v143</PlatformToolset>
    <UseOfMfc>false</UseOfMfc>
    <CharacterSet>MultiByte</CharacterSet>
  </PropertyGroup>
  <Import Project=\"\$\(VCTargetsPath)\\Microsoft.Cpp.props\" />
  <ImportGroup Label=\"ExtensionSettings\">
  </ImportGroup>
  <ImportGroup Label=\"Shared\">
  </ImportGroup>
  <ImportGroup Label=\"PropertySheets\" Condition=\"'\$\(Configuration)|\$\(Platform)'=='Debug|Win32'\">
    <Import Project=\"\$\(UserRootDir)\\Microsoft.Cpp.\$\(Platform).user.props\" Condition=\"exists('\$\(UserRootDir)\\Microsoft.Cpp.\$\(Platform).user.props')\" Label=\"LocalAppDataPlatform\" />
  </ImportGroup>
  <ImportGroup Label=\"PropertySheets\" Condition=\"'\$\(Configuration)|\$\(Platform)'=='Release|Win32'\">
    <Import Project=\"\$\(UserRootDir)\\Microsoft.Cpp.\$\(Platform).user.props\" Condition=\"exists('\$\(UserRootDir)\\Microsoft.Cpp.\$\(Platform).user.props')\" Label=\"LocalAppDataPlatform\" />
  </ImportGroup>
  <PropertyGroup Label=\"UserMacros\" />
  <PropertyGroup Condition=\"'\$\(Configuration)|\$\(Platform)'=='Debug|Win32'\">
    <OutDir>.\\Debug${modis_suffix}\\</OutDir>
    <IntDir>.\\Debug${modis_suffix}\\</IntDir>
    <LinkIncremental>true</LinkIncremental>
  </PropertyGroup>
  <PropertyGroup Condition=\"'\$\(Configuration)|\$\(Platform)'=='Release|Win32'\">
    <OutDir>.\\Release${modis_suffix}\\</OutDir>
    <IntDir>.\\Release${modis_suffix}\\</IntDir>
    <LinkIncremental>false</LinkIncremental>
  </PropertyGroup>
  <ItemDefinitionGroup Condition=\"'\$\(Configuration)|\$\(Platform)'=='Debug|Win32'\">
    <Midl>
      <TypeLibraryName>.\\Debug${modis_suffix}\\MoDIS.tlb</TypeLibraryName>
      <HeaderFileName />
    </Midl>
    <ClCompile>
      <AdditionalOptions>/MP /J %(AdditionalOptions)</AdditionalOptions>
      <Optimization>Disabled</Optimization>
      <PreprocessorDefinitions>WIN32;_DEBUG;_CONSOLE;_CRT_SECURE_NO_WARNINGS;$option_in_ini;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <MinimalRebuild>false</MinimalRebuild>
      <RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>
      <PrecompiledHeaderOutputFile>.\\Debug${modis_suffix}\\MoDIS.pch</PrecompiledHeaderOutputFile>
      <AssemblerListingLocation>.\\Debug${modis_suffix}\\</AssemblerListingLocation>
      <ObjectFileName>.\\Debug${modis_suffix}\\</ObjectFileName>
      <ProgramDataBaseFileName>.\\Debug${modis_suffix}\\</ProgramDataBaseFileName>
      <BrowseInformation>true</BrowseInformation>
      <WarningLevel>Level3</WarningLevel>
      <SuppressStartupBanner>true</SuppressStartupBanner>
      <DebugInformationFormat>ProgramDatabase</DebugInformationFormat>
      <ForcedIncludeFiles>auto_header.h;%(ForcedIncludeFiles)</ForcedIncludeFiles>
      <DisableSpecificWarnings>4996;%(DisableSpecificWarnings)</DisableSpecificWarnings>
      <AdditionalIncludeDirectories>$incl_set;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
    </ClCompile>
    <ResourceCompile>
      <PreprocessorDefinitions>_DEBUG;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <Culture>0x0404</Culture>
    </ResourceCompile>
    <Link>
      <AdditionalDependencies>winmm.lib;odbc32.lib;odbccp32.lib;ws2_32.lib;Msimg32.lib;Debug\\MoDis_UI.lib;$linker_inp;%(AdditionalDependencies)</AdditionalDependencies>
      <OutputFile>.\\Debug${modis_suffix}\\MoDIS.exe</OutputFile>
      <SuppressStartupBanner>true</SuppressStartupBanner>
      <UACExecutionLevel>RequireAdministrator</UACExecutionLevel>
      <IgnoreSpecificDefaultLibraries>libc.lib;libcp.lib;libcd.lib;libcmt.lib;%(IgnoreSpecificDefaultLibraries)</IgnoreSpecificDefaultLibraries>
      <GenerateDebugInformation>true</GenerateDebugInformation>
      <ProgramDatabaseFile>.\\Debug${modis_suffix}\\MoDIS.pb</ProgramDatabaseFile>
      <GenerateMapFile>true</GenerateMapFile>
      <MapFileName>.\\Debug${modis_suffix}\\MoDIS.map</MapFileName>
      <SubSystem>Console</SubSystem>
      <RandomizedBaseAddress>false</RandomizedBaseAddress>
      <DataExecutionPrevention />
      <TargetMachine>MachineX86</TargetMachine>
      <ImageHasSafeExceptionHandlers>false</ImageHasSafeExceptionHandlers>
    </Link>
    <Bscmake>
      <SuppressStartupBanner>true</SuppressStartupBanner>
      <OutputFile>.\\Debug${modis_suffix}\\MoDIS.bsc</OutputFile>
    </Bscmake>
  </ItemDefinitionGroup>
  <ItemDefinitionGroup Condition=\"'\$\(Configuration)|\$\(Platform)'=='Release|Win32'\">
    <Midl>
      <TypeLibraryName>.\\Release${modis_suffix}\\MoDIS.tlb</TypeLibraryName>
      <HeaderFileName />
    </Midl>
    <ClCompile>
      <AdditionalOptions>/MP /J %(AdditionalOptions)</AdditionalOptions>
      <Optimization>Disabled</Optimization>
      <PreprocessorDefinitions>WIN32;NDEBUG;_CONSOLE;_CRT_SECURE_NO_WARNINGS;$option_in_ini;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <MinimalRebuild>false</MinimalRebuild>
      <RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>
      <BufferSecurityCheck>false</BufferSecurityCheck>
      <PrecompiledHeaderOutputFile>.\\Release${modis_suffix}\\MoDIS.pch</PrecompiledHeaderOutputFile>
      <AssemblerListingLocation>.\\Release${modis_suffix}\\</AssemblerListingLocation>
      <ObjectFileName>.\\Release${modis_suffix}\\</ObjectFileName>
      <ProgramDataBaseFileName>.\\Release${modis_suffix}\\</ProgramDataBaseFileName>
      <WarningLevel>Level3</WarningLevel>
      <SuppressStartupBanner>true</SuppressStartupBanner>
      <DebugInformationFormat>ProgramDatabase</DebugInformationFormat>
      <ForcedIncludeFiles>auto_header.h;%(ForcedIncludeFiles)</ForcedIncludeFiles>
      <DisableSpecificWarnings>4996;%(DisableSpecificWarnings)</DisableSpecificWarnings>
      <AdditionalIncludeDirectories>$incl_set;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
    </ClCompile>
    <ResourceCompile>
      <PreprocessorDefinitions>NDEBUG;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <Culture>0x0404</Culture>
    </ResourceCompile>
    <Link>
      <AdditionalDependencies>Gdi32.lib;ole32.lib;user32.lib;winmm.lib;odbc32.lib;odbccp32.lib;ws2_32.lib;Msimg32.lib;Release\\MoDis_UI.lib;$linker_inp;%(AdditionalDependencies)</AdditionalDependencies>
      <OutputFile>.\\Release${modis_suffix}\\MoDIS.exe</OutputFile>
      <SuppressStartupBanner>true</SuppressStartupBanner>
      <UACExecutionLevel>RequireAdministrator</UACExecutionLevel>
      <IgnoreSpecificDefaultLibraries>LIBCD.lib;LIBC.lib;%(IgnoreSpecificDefaultLibraries)</IgnoreSpecificDefaultLibraries>
      <ProgramDatabaseFile>.\\Release${modis_suffix}\\MoDIS.pdb</ProgramDatabaseFile>
      <SubSystem>Console</SubSystem>
      <RandomizedBaseAddress>false</RandomizedBaseAddress>
      <DataExecutionPrevention />
      <TargetMachine>MachineX86</TargetMachine>
      <ImageHasSafeExceptionHandlers>false</ImageHasSafeExceptionHandlers>
    </Link>
    <Bscmake>
      <SuppressStartupBanner>true</SuppressStartupBanner>
      <OutputFile>.\\Release${modis_suffix}\\MoDIS.bsc</OutputFile>
    </Bscmake>
  </ItemDefinitionGroup>
__STRING__
;
	return $result;
}

sub create_main_Files_List
{
	my $lib = shift;
	my $file_list = shift;
	my $WIN32_COMPILE_OPTION = shift;
	my $lib_list = shift;

	my @file_src;
	my @file_inc;
	my @file_pic;
	my @file_res;
	my @file_libs;
	my @file_obj;
	foreach my $file (split("\n",$file_list))
	{
		chomp($file);
		$file = short_path($file);
		if ($file =~ /\.c(pp|xx)?$/i)
		{
			push(@file_src, $file);
		}
		elsif ($file =~ /\.h(pp|xx)?$/i)
		{
			push(@file_inc, $file);
		}
		elsif ($file =~ /\.(rc)$/i)
		{
			push(@file_res, $file);
		}
		else
		{
			push(@file_pic, $file);
		}
	}

	foreach my $file (@$lib_list)
	{
		$file = short_path($file);
		if ($file =~ /\.(lib)$/i)
		{
			push(@file_libs, $file);
		}
		else
		{
			push(@file_obj, $file);
		}
	}

	my $result_src = "  <ItemGroup>\n";
	foreach my $file (@file_src)
	{
		$result_src .= "    <ClCompile Include=\"$file\"/>\n";
	}
	$result_src .= "  </ItemGroup>\n";

	my $result_inc = "  <ItemGroup>\n";
	foreach my $file (@file_inc)
	{
		$result_inc .= "    <ClInclude Include=\"$file\"/>\n";
	}
	$result_inc .= "  </ItemGroup>\n";

	my $result_res = "  <ItemGroup>\n";
	foreach my $file (@file_pic)
	{
		$result_res .= "    <Image Include=\"$file\"/>\n";
	}
	$result_res .= "  </ItemGroup>\n  <ItemGroup>\n";
	foreach my $file (@file_res)
	{
		$result_res .= "    <ResourceCompile Include=\"$file\"/>\n";
	}
	$result_res .= "  </ItemGroup>\n";

	my $result_lib =  "  <ItemGroup>\n";
	foreach my $file (@file_libs)
	{
		$result_lib .= "    <Library Include=\"$file\"/>\n";
	}
	$result_lib .= "  </ItemGroup>\n  <ItemGroup>\n";
	foreach my $file (@file_obj)
	{
		$result_lib .= "    <Object Include=\"$file\"/>\n";
	}
	$result_lib .= "  </ItemGroup>\n";

	my $result = $result_src;
	$result .= $result_inc;
	$result .= $result_res;
	$result .= $result_lib;

	return $result;
}

# =================================================================
# VS2008 cannot parse .vcproj files in which there are 2 or more <FILTER> section with the same name
# The function here is to parse generated .vcproj files
# and rename the duplicated section name to ORGINNAME_1/2/3...
# E.g.: "src" => "src_1" or "src_2", etc.
# sub checkVcprojFile
# {
# 	my $inputVcproj = shift;
# 	my $filterFlag = 0;
# 	my $filterCount = 0;
# 	my @filter;
# 	my $content = "";
# 	my $count = 0;
# 	foreach (split(/\n/,$inputVcproj)) {
# 		$_ .= "\n";
# 		if (/<Filter/) {
# 			$filterCount = $filterCount + 1; $filterFlag = 1; $content .= $_;
# 			next;
# 		}
# 		if (/<\/Filter>/) {
# 			$filterCount = $filterCount - 1; $content .= $_;
# 			next;
# 		}
# 		if (($filterFlag == 1) && ($filterCount == 1)) {
# 			if (/Name\s*=\s*\"([a-zA-Z0-9]+)\"/) {
# 				if (grep (/\b$1\b/, @filter)) {
# 					$count = $count + 1;
# 					$_ =~ s/\"([a-zA-Z0-9]+)\"/\"$1_$count\"/;
# 				} else {
# 					push @filter, $1;
# 				}
# 			}
# 			if (/^\s*$/) { #empty line
# 				next;
# 			}
# 			$filterFlag = 0;
# 		}
# 		$content .= $_;
# 	}
# 	return $content;
# }

sub update_lib_project
{
	my $old_project = shift;
	my $new_project = shift;
	my $release_MoDIS_lib = shift;
	my $list = shift;
	my $cleanRoomLibRemoval = shift;

	open F,"<$old_project" or die "Can't open $old_project";
	my $content = join('',<F>);
	close F;
	my $content1 = $content;
	my $path_MoDIS_lib = $release_MoDIS_lib;
	$path_MoDIS_lib =~ s/(\\+)/\\\\/g;
	if ($content1 !~ /$path_MoDIS_lib/i)
	{
		$content1 =~ s/\bMoDIS_lib\b/$release_MoDIS_lib/gi;
	}
	#$content =~ /(<File\s*RelativePath=.*supc.*\s+>\s+<\/File>)/ig;
	#my $cleanRoomLib = $1;
	my $cleanRoomLib = "";

	if ($content1 =~ /<ItemGroup>(.*?)<\/ItemGroup>/is) {
	    my $t;
	    foreach my $line (split('\n', $list)) {
	        if ($line) {
	            $t .= "\n    <Library Include=\"$line\"/>";
	        }
	    }
		
	    my $insertion_point = -1;
	    while ($content1 =~ m/<\/ItemGroup>/g) {
	        $insertion_point = pos($content1) - length('</ItemGroup>');
	    }
	    
	    if ($insertion_point != -1) {
	        my $start = substr($content1, 0, $insertion_point);
	        my $end = substr($content1, $insertion_point);
	        $content1 = $start . $t . $end;
	    } else {
	        goto CREATE_NEW_ITEMGROUP;
	    }
	} else {
	    CREATE_NEW_ITEMGROUP:
	    my $t = "  <ItemGroup>";
	    
	    foreach my $line (split('\n', $list)) {
	        if ($line) {
	            $t .= "\n    <Library Include=\"$line\"/>";
	        }
	    }

	    if ($cleanRoomLibRemoval eq "FALSE") {
	        $t .= $cleanRoomLib;
	    }
	    
	    $t .= "\n  </ItemGroup>\n";

	    $content1 =~ s/<\/Project>/$t<\/Project>/;
	}
	if ($new_project =~ /MoDIS_Custom/i) # the output of MoDIS_Custom.sln should be MoDIS_Custom.exe
	{
		$content1 =~ s/\bMoDIS\.exe\b/MoDIS_Custom\.exe/gi;
		$content1 =~ s/\bMoDIS\.pdb\b/MoDIS_Custom\.pdb/gi;
	}
	open F,">$new_project" or die "Can't write $new_project";
	print F $content1;
	close F;
}

sub generate
{
  my($out, $in, $cwd) = @_;
  my $chash = hash($cwd);
  my $nhash = hash($out);
  my $ihash = hash($in);
  my $val   = 0xfeca1bad;

  return sprintf("%08X-%04X-%04X-%04X-%04X%08X",
                 $nhash & 0xffffffff, ($val >> 16) & 0xffff,
                 ($val & 0xffff), ($ihash >> 16) & 0xffff,
                 $ihash & 0xffff, $chash & 0xffffffff);
}

sub hash
{
  my $str   = shift;
  my $value = 0;

  if (defined $str) {
    my $length = length($str);
    for(my $i = 0; $i < $length; $i++) {
      $value = (($value << 4) & 0xffffffff) ^ ($value >> 28)
        ^ ord(substr($str, $i, 1));
    }
  }

  return $value;
}

sub short_path
{
	my $input = shift;
	$input =~ s/[\\\/]+/\\/g;
	$input =~ s/^\s*\\I\b/\/I/;
	while ($input =~ /\\\.\\/)
	{
		$input =~ s/\\\.\\/\\/g;
	}
	while ($input =~ /\w+\\\.\.\\/)
	{
		$input =~ s/\w+\\\.\.\\//;
	}
	return $input;
}

sub CheckIfFolder
{
	my $name = shift;
	if (opendir DH, $name)
	{
		closedir DH;
		#print "$name => 1\n";
		return 1;
	}
	#print "$name => 0\n";
	return 0;
}

sub CopyFolder
{
	my $src = shift;
	my $target = shift;
	my $flag = shift;
	my $DIRHANDLE;
	mkpath($target) if (! -e $target);
	opendir $DIRHANDLE, $src or die "Can't Open $src, Information:$!!\n";
	my @dirs = readdir $DIRHANDLE;
	closedir $DIRHANDLE;
	foreach my $fd (@dirs)
	{
		next if ($fd =~ /^(\.|\.\.)$/);
		my $input2 = "$src\\$fd";
		my $output3 = "$target\\$fd";
		if (CheckIfFolder($input2))
		{
			# directory
			next if ($flag);
			CopyFolder($input2, $output3);
		}
		elsif (-e $input2)
		{
			# file, copy directly
			next if (($flag) && ($fd =~ /^(MoDIS|vc90|vc143)\.(pdb|idb|bsc|ilk)$/i));
			copy($input2, $output3) or die "Fail to copy $src\\$fd: $!\n";
		}
		else
		{
			die "Fail to find $src\\$fd: $!\n";
		}
	}
}

sub CopyFile
{
	my $src = shift;
	my $target = shift;
	my $dest = dirname($target);
	mkpath($dest) if (! CheckIfFolder($dest));
	copy($src, $target) or die "Fail to copy $src";
}

sub auto_header
{
	# working dir is mcu
	my $ref_str_out = shift;
	my $ref_hash_out = shift;
	my $ref_str_in = shift;
	my $str_prefix = shift;
	my $flag_target = shift;
	my %file_header = ("lib_list"=>"");
	my @path_list = split(/\s+/, $$ref_str_in);
	my %saw;
	my $put_il_fix = 0;
	@path_list = grep (!$saw{$_}++, @path_list);
	foreach my $dir (@path_list)
	{
		next if (($dir eq "") || (!-d $dir));
		#print "auto_header for " . $dir . "\n";
		my $DIR_HANDLE;
		opendir $DIR_HANDLE, $dir or die "Fail to opendir " . $dir;
		my @file_list = readdir $DIR_HANDLE;
		close $DIR_HANDLE;
		foreach my $file (@file_list)
		{
			next if (($file eq ".") || ($file eq ".."));
			next if ((lc($file) eq "readme.txt") || (lc($file) eq "dummy.txt") || (lc($file) eq "temp.txt") || (lc($file) eq "makefile"));
			next if ($file =~ /\.(vcxproj|rar|pch|dll)$/i);
			if (-d "$dir/$file")
			{
			}
			elsif (-e "$dir/$file")
			{
				if (exists $file_header{lc($file)})
				{
					$ref_hash_out->{$dir} .= $file . " ";
					$ref_hash_out->{$file_header{lc($file)}} .= $file . " ";
				}
				else
				{
					$file_header{lc($file)} = $dir;
				}
			}
		}
	}
	my $key;
	my $value;
	while (($key, $value) = each %file_header)
	{
		if (! exists $ref_hash_out->{$value})
		{
			my $full_path;
			$full_path = short_path("$str_prefix/$value/$key");
			if ($flag_target == 0)
			{
				#error C2735: 'inline' keyword is not permitted in formal parameter type specifier
				if ($put_il_fix == 0)
				{
					$$ref_str_out .= "#ifdef __cplusplus\n#else\n#define inline m_inline\n#endif\n";
					$put_il_fix = 1;
				}
				$$ref_str_out .= "#pragma include_alias(\"" . $key . "\", \"" . $full_path . "\")\n";
			}
			else
			{
				if ($^O eq "MSWin32")
				{
					$$ref_str_out .= "copy /y " . $full_path . " %1\n";
				}
				else
				{
				}
			}
		}
	}
	
	return 1;
}

return 1;

