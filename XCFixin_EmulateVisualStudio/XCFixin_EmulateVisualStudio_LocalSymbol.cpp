
#include <mach-o/dyld.h>
#include <string.h>
#include <mach-o/nlist.h>
#include <mach-o/stab.h>
#include <cstdio>
#include <map>
#include <string>

#if __LP64__
#define RELOC_SIZE 3
#define LC_SEGMENT_COMMAND		LC_SEGMENT_64
#define LC_ROUTINES_COMMAND		LC_ROUTINES_64
struct macho_header				: public mach_header_64  {};
struct macho_segment_command	: public segment_command_64  {};
struct macho_section			: public section_64  {};
//struct macho_nlist				: public nlist_64  {};
struct macho_routines_command	: public routines_command_64  {};
#else
#define RELOC_SIZE 2
#define LC_SEGMENT_COMMAND		LC_SEGMENT
#define LC_ROUTINES_COMMAND		LC_ROUTINES
struct macho_header				: public mach_header  {};
struct macho_segment_command	: public segment_command {};
struct macho_section			: public section  {};
//struct macho_nlist				: public nlist  {};
struct macho_routines_command	: public routines_command  {};
#endif

struct CModuleCache
{
	bool m_bCreated = false;
	std::map<std::string, void *> m_Functions;
};

std::map<std::string, CModuleCache> g_ModuleCache;

static CModuleCache &fg_GetModuleCache(char const *_pImageName)
{
	auto &Module = g_ModuleCache[_pImageName];

	if (Module.m_bCreated)
		return Module;

	Module.m_bCreated = true;

	macho_header const *pHeader = nullptr;

	auto nImages = _dyld_image_count();
	for (auto i = 0; i < nImages; ++i)
	{
		auto *pImageName = _dyld_get_image_name(i);
		if (strstr(pImageName, _pImageName))
		{
			pHeader = (macho_header const *)_dyld_get_image_header(i);
			break;
		}
	}

	if (!pHeader)
		return Module;

	const uint8_t *pMachOData = (uint8_t const *)pHeader;
	const uint8_t *pFileData = nullptr;

	const uint32_t cmd_count = pHeader->ncmds;
	const struct load_command* const cmds = (struct load_command*) ((char *)pHeader + sizeof(struct macho_header));
	const struct load_command* cmd = cmds;

	const struct symtab_command *pSymTab;
	for (uint32_t i = 0; i < cmd_count; ++i)
	{
		switch (cmd->cmd)
		{
		case LC_SEGMENT_COMMAND:
			{
				const struct macho_segment_command* seg = (struct macho_segment_command*)cmd;
				if (strcmp(seg->segname, "__LINKEDIT") == 0)
					pFileData = pMachOData + (seg->vmaddr - seg->fileoff);
			}
			break;
		case LC_SYMTAB:
			{
				pSymTab = (struct symtab_command*)cmd;
			}
			break;
		}
		cmd = (const struct load_command*)(((char*)cmd)+cmd->cmdsize);
	}

	if (!pSymTab)
		return Module;

	auto fLinkEditAddr = [&](size_t _Offset)
		{
			return (uint8_t const*)(pFileData + _Offset);
		}
	;

	nlist_64 *pEntries = (nlist_64 *)(fLinkEditAddr(pSymTab->symoff));
	char const *pStringTable = (char const *)fLinkEditAddr(pSymTab->stroff);

	for (size_t iEntry = 0; iEntry < pSymTab->nsyms; ++iEntry)
	{
		auto &Entry = pEntries[iEntry];

		if (Entry.n_un.n_strx == 0 || (Entry.n_type & N_STAB) || ((Entry.n_type & N_TYPE) != N_SECT))
			continue;

		char const *pName = pStringTable + Entry.n_un.n_strx;
		Module.m_Functions[pName] = (void *)(pMachOData + Entry.n_value);
	}

	return Module;
}

extern "C" void *fg_GetLocalSymbol(char const *_pImageName, char const *_pSymbolName)
{
	auto &Cache = fg_GetModuleCache(_pImageName);

	auto iFound = Cache.m_Functions.find(_pSymbolName);
	if (iFound == Cache.m_Functions.end())
		return nullptr;

	return iFound->second;
}
