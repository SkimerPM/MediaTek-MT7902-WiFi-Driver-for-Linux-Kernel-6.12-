#include <linux/module.h>
#include <linux/export-internal.h>
#include <linux/compiler.h>

MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__section(".gnu.linkonce.this_module") = {
	.name = KBUILD_MODNAME,
	.arch = MODULE_ARCH_INIT,
};

KSYMTAB_FUNC(btmtk_fw_get_filename, "_gpl", "");
KSYMTAB_FUNC(btmtk_setup_firmware_79xx, "_gpl", "");
KSYMTAB_FUNC(btmtk_setup_firmware, "_gpl", "");
KSYMTAB_FUNC(btmtk_set_bdaddr, "_gpl", "");
KSYMTAB_FUNC(btmtk_reset_sync, "_gpl", "");
KSYMTAB_FUNC(btmtk_register_coredump, "_gpl", "");
KSYMTAB_FUNC(btmtk_process_coredump, "_gpl", "");
KSYMTAB_FUNC(btmtk_usb_subsys_reset, "_gpl", "");
KSYMTAB_FUNC(btmtk_usb_recv_acl, "_gpl", "");
KSYMTAB_FUNC(alloc_mtk_intr_urb, "_gpl", "");
KSYMTAB_FUNC(btmtk_usb_resume, "_gpl", "");
KSYMTAB_FUNC(btmtk_usb_suspend, "_gpl", "");
KSYMTAB_FUNC(btmtk_usb_setup, "_gpl", "");
KSYMTAB_FUNC(btmtk_usb_shutdown, "_gpl", "");

SYMBOL_CRC(btmtk_fw_get_filename, 0xbc8bf0c0, "_gpl");
SYMBOL_CRC(btmtk_setup_firmware_79xx, 0x756038d6, "_gpl");
SYMBOL_CRC(btmtk_setup_firmware, 0xa89d138f, "_gpl");
SYMBOL_CRC(btmtk_set_bdaddr, 0xa5cb0ca4, "_gpl");
SYMBOL_CRC(btmtk_reset_sync, 0xbd06be46, "_gpl");
SYMBOL_CRC(btmtk_register_coredump, 0x4c457927, "_gpl");
SYMBOL_CRC(btmtk_process_coredump, 0x5f69ff9b, "_gpl");
SYMBOL_CRC(btmtk_usb_subsys_reset, 0xdffe685c, "_gpl");
SYMBOL_CRC(btmtk_usb_recv_acl, 0x6b1d3da9, "_gpl");
SYMBOL_CRC(alloc_mtk_intr_urb, 0x6c798630, "_gpl");
SYMBOL_CRC(btmtk_usb_resume, 0x58308091, "_gpl");
SYMBOL_CRC(btmtk_usb_suspend, 0xcf2511b5, "_gpl");
SYMBOL_CRC(btmtk_usb_setup, 0x8abaa33e, "_gpl");
SYMBOL_CRC(btmtk_usb_shutdown, 0x74602baa, "_gpl");

static const struct modversion_info ____versions[]
__used __section("__versions") = {
	{ 0xbdfb6dbb, "__fentry__" },
	{ 0x656e4a6e, "snprintf" },
	{ 0xf4375e04, "request_firmware" },
	{ 0x718b8b7, "bt_info" },
	{ 0xc3055d20, "usleep_range_state" },
	{ 0x362f9a8, "__x86_indirect_thunk_r12" },
	{ 0xf9a482f9, "msleep" },
	{ 0x7b8c32f1, "bt_err" },
	{ 0x5b8239ca, "__x86_return_thunk" },
	{ 0xc6d09aa9, "release_firmware" },
	{ 0xf0fdf6cb, "__stack_chk_fail" },
	{ 0x73e33847, "__hci_cmd_sync" },
	{ 0x8de6fe16, "sk_skb_reason_drop" },
	{ 0x4dfa8d4b, "mutex_lock" },
	{ 0xbb654870, "hci_cmd_sync_queue" },
	{ 0x3213f038, "mutex_unlock" },
	{ 0x8a05b330, "hci_devcd_register" },
	{ 0xb6ff6a40, "__hci_cmd_send" },
	{ 0x9996c2e6, "usb_alloc_urb" },
	{ 0x52c5c991, "__kmalloc_noprof" },
	{ 0x6ebe366f, "ktime_get_mono_fast_ns" },
	{ 0x6d586b65, "usb_anchor_urb" },
	{ 0xf264a1a6, "usb_submit_urb" },
	{ 0xa2087e44, "usb_free_urb" },
	{ 0x2cf56265, "__dynamic_pr_debug" },
	{ 0x48db5758, "usb_unanchor_urb" },
	{ 0x962c8ae1, "usb_kill_anchored_urbs" },
	{ 0x69acdf38, "memcpy" },
	{ 0xd2a5b63f, "usb_autopm_get_interface" },
	{ 0xc4aa18f, "kmalloc_caches" },
	{ 0xd8ba0fc0, "__kmalloc_cache_noprof" },
	{ 0xd0fae0b2, "usb_autopm_put_interface" },
	{ 0xe2c17b5d, "__SCT__might_resched" },
	{ 0x37a0cba, "kfree" },
	{ 0x44bae227, "bit_wait_timeout" },
	{ 0x4071b517, "out_of_line_wait_on_bit_timeout" },
	{ 0x75ca79b5, "__fortify_panic" },
	{ 0x76e0b328, "hci_devcd_append" },
	{ 0x43aabb0c, "hci_devcd_complete" },
	{ 0x696d474d, "hci_devcd_init" },
	{ 0x2d3385d3, "system_wq" },
	{ 0xb2fcb56d, "queue_delayed_work_on" },
	{ 0xe183ce4e, "usb_disable_autosuspend" },
	{ 0xbd13d3dd, "skb_clone" },
	{ 0x2114dc0, "hci_recv_diag" },
	{ 0x18fc2a0c, "hci_recv_frame" },
	{ 0x69350706, "usb_set_interface" },
	{ 0xeae3dfd6, "__const_udelay" },
	{ 0x2c57fc98, "__alloc_skb" },
	{ 0xb84d4c09, "skb_put" },
	{ 0xa0fbac79, "wake_up_bit" },
	{ 0x85da03be, "usb_control_msg" },
	{ 0xea5d07bb, "__skb_pad" },
	{ 0xb43f9365, "ktime_get" },
	{ 0x38b296ba, "hci_cmd_sync_cancel" },
	{ 0x34db050b, "_raw_spin_lock_irqsave" },
	{ 0xd35cce70, "_raw_spin_unlock_irqrestore" },
	{ 0xa916b694, "strnlen" },
	{ 0xbf1981cb, "module_layout" },
};

MODULE_INFO(depends, "bluetooth,usbcore");


MODULE_INFO(srcversion, "42D062A2DCF9DD07EDE289A");
