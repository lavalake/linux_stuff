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
