#include <efi.h>
#include <efilib.h>

EFI_STATUS efi_main(EFI_HANDLE image_handle, EFI_SYSTEM_TABLE *systab ){
	InitializeLib(image_handle, systab);
	int i,z;
	long long int k=0;	
	EFI_BOOT_SERVICES *efi_bs; efi_bs= systab->BootServices;
	SIMPLE_TEXT_OUTPUT_INTERFACE *conout; conout = systab->ConOut;
	EFI_STATUS jas;
	UINTN my_memmapsize, my_mapkey, my_descrsize;;
	UINT32 my_descrver;
	EFI_MEMORY_DESCRIPTOR *my_memmap;
	EFI_MEMORY_TYPE my_pooltype=EfiLoaderData;
	

	//узнаем нужный размер памяти
	jas=uefi_call_wrapper(efi_bs->GetMemoryMap,5,&my_memmapsize, my_memmap, &my_mapkey, &my_descrsize, &my_descrver);  
	if(jas!=EFI_BUFFER_TOO_SMALL){Print(L"Error in getting memory map, str19\n");return EFI_SUCCESS;}

	
	//выделяем память	
	jas=uefi_call_wrapper(efi_bs->AllocatePool,3, my_pooltype,my_memmapsize, ((void*)&my_memmap));  
	if(jas!=EFI_SUCCESS){Print(L"Error in allocating memory, str24\n");return EFI_SUCCESS;}

	
	
	//считываем карту памяти
	jas=uefi_call_wrapper(efi_bs->GetMemoryMap, 5, &my_memmapsize, my_memmap, &my_mapkey, &my_descrsize, &my_descrver);  
	if(jas!=EFI_SUCCESS){Print(L"Error in getting memory map, str30\n");return EFI_SUCCESS;}
	
	
	//считаем результат
	z=my_memmapsize/(sizeof(EFI_MEMORY_DESCRIPTOR));	
	for(i=0;i<z;i++){
		if((my_memmap[i].Type == EfiBootServicesCode)|| (my_memmap[i].Type ==EfiBootServicesData) ||(my_memmap[i].Type ==EfiConventionalMemory)){k+=my_memmap[i].NumberOfPages;}
	}
	k=k*4096;

	jas=uefi_call_wrapper(efi_bs->FreePool, 1, ((void*)my_memmap));
	if(jas!=EFI_SUCCESS){Print(L"Error in free pool fuction, str41\n");return jas;}


	Print(L"%d bytes of memory available for general use\n",k);
	return EFI_SUCCESS;
}
