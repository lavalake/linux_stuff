
Mem alloc
	kmalloc
	kmem_cache_create
	kmem_pool
	__get_free_pages
	vmalloc
	alloc_pages

kmalloc
	GFP_KERNEL: run in kernel process context. Calling this function will cause the process to sleep. can not call in atomic context
	GFP_ATOMIC: when run in non-process contxt which can not sleep, such as interrupt service, tasklet, timer, can not call GFP_KERNEL. should use GFP_ATOMIC. If there is not enough memory, allocation will fail.

Memory type 
	DMA-capable
	normal
	high memory
allocation size
	kernel can only allocate predefined fixd-size memory. All memory are in fixed-size pools
	smalleset allocation size is 32 or 64 depending on the page size of the system?

slab allocator

kmalloc\vmalloc\ioremap
	all virtual address, differenct?
	
per cpu variable
	no locking
	
RW Semaphore

large buffer
	scatter\gather
io port
	no caching and no reordering when access registers
	must call different function to access different size ports
	use memory barrier
		barrier
		rmb\wmb\mb\read_barrier_depends
		smp_rmb\wmb\mb
	pci cache issue?

	/proc/ioports
	/proc/iomem
	request_region()
	no 64 bit port io operation defined. Only 32 bit
	inb\inw\inl\outb\outw\outl
	user space io port access
		ioperm
		iopl
		use /dev/port to access
	for portability purpose, use wrapper fucntion to access io ports, not use pointer
	only x86 has different address space for ports and RAM
	ioport_remap() from 2.6
/proc/pid/maps
mmap
	device driver implement mmap to map the device memory to user-space process address space
	when user space process call mmap, kernel will create a new vma
device memory mapping
	map device memory to user space.
	mapping is page size grained
	remap_pfn_range
The prerequisite to understand these memory mapping concepts is to know the concepts of virtual memory.
For example, in a 32-bit architecture CPU can generate 2^32 addresses i-e. it can virtually address upto 4GB of memory. In general, kernel is assigned 1GB(also called LOW memory) and User space is assigned 3GB(also called HIGH memory). 
1. mmap: Normally user space processes can't access device memory directly for security purpose. So, user space processes use the mmap system call to ask kernel to map the device into virtual address space of the calling process. After the mapping the user space process can write directly into the device memory via the returned address.

The mmap system call is declared as follows:
mmap (caddr_t addr, size_t len, int prot, int flags, int fd, off_t offset);

Where as, the mmap field in the driver's file operation structure is declared as:
int (*mmap) (struct file *filp, struct vm_area_struct *vma); 
You can get the details about these declaration from manuals.

2. ioremap: ioremap is used to map physical memory into virtual address space of the kernel. 
In most of the system now a days, the devices are memory mapped to the system. That means, kernel can access these device registers by writing directly into these physical memory addresses. But, when MMU is enabled in a system, the kernel works on virtual memory. So, the physical address has to be mapped into virtual address first before the kernel can access these devices and perform IO. ioremap call does exactly that. 
The ioremap declaration is as follows:
void *ioremap(unsigned long phys_addr, unsigned long size);

3. kmap: To understand kmap, you need to have some understanding about Memory Management Unit (MMU) and the page tables.

In a 32-bit system, generally a page is of size 4KB. Every physical page is represented by a structure struct page. The mapping of virtual to physical address translation is stored in the page tables. So, when a process does some operation on virtual address, then MMU first translates the virtual address into physical address, and then operation could be performed on actual physical memory.

The pages in low memory is always permanently mapped to kernel address space, but the pages in high memory might not be permanently mapped into the kernel’s
address space. As I have explained before if MMU is enabled, kernel always works on virtual address space. If you have the physical page structure, then first it needs to have a mapping in kernel's virtual address space and only then we can use it.

kmap is used to map a given page structure into the kernel’s address space.
The declaration of kmap is as follows:
void *kmap(struct page *page);

This function works on both High memory and Low memory.
If the page structure belongs to a page in low memory, then just the virtual address of the page is returned. (Note that Low memory pages already have permanent mappings)

If the page resides in high memory, a permanent mapping is created in the page tables and then the address is returned.

Also note that the permanent mappings are limited, so best programming practice is to unmap High memory mappings when it's no longer required. This can be done via:
void kunmap(struct page *page);
