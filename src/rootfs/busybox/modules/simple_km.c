#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENSE("GPL v2");
MODULE_AUTHOR("Mario Konrad <mario.konrad@bbv.ch>");
MODULE_DESCRIPTION("Simple kernel module for demonstration");

static int __init simple_module_init(void)
{
	printk(KERN_INFO "simple_module init. module loaded.\n");
	return 0;
}

static void __exit simple_module_cleanup(void)
{
	printk(KERN_INFO "simple_module cleanup. module unloaded.\n");
}

module_init(simple_module_init);
module_exit(simple_module_cleanup);

