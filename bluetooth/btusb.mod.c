#include <linux/module.h>
#include <linux/export-internal.h>
#include <linux/compiler.h>

MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__section(".gnu.linkonce.this_module") = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};



static const struct modversion_info ____versions[]
__used __section("__versions") = {
	{ 0xf4375e04, "request_firmware" },
	{ 0xc6d09aa9, "release_firmware" },
	{ 0xa4239d34, "device_remove_file" },
	{ 0xe6dc12f, "hci_unregister_dev" },
	{ 0x6bb9c8, "gpiod_put" },
	{ 0x3e0b65fb, "hci_free_dev" },
	{ 0xe91fe0f8, "device_wakeup_disable" },
	{ 0x2d3385d3, "system_wq" },
	{ 0xc5b6f236, "queue_work_on" },
	{ 0x2c57fc98, "__alloc_skb" },
	{ 0xb84d4c09, "skb_put" },
	{ 0x6c798630, "alloc_mtk_intr_urb" },
	{ 0x3dad9978, "cancel_delayed_work" },
	{ 0xd1f8f52, "skb_queue_purge_reason" },
	{ 0xdffe685c, "btmtk_usb_subsys_reset" },
	{ 0x807766ea, "usb_scuttle_anchored_urbs" },
	{ 0x5a6f8d0d, "usb_get_from_anchor" },
	{ 0x3ce4ca6f, "disable_irq" },
	{ 0x69acdf38, "memcpy" },
	{ 0x8d522714, "__rcu_read_lock" },
	{ 0x2469810f, "__rcu_read_unlock" },
	{ 0x1f571f6d, "skb_queue_tail" },
	{ 0xb2fcb56d, "queue_delayed_work_on" },
	{ 0x2114dc0, "hci_recv_diag" },
	{ 0x69350706, "usb_set_interface" },
	{ 0x8c8569cb, "kstrtoint" },
	{ 0xa916b694, "strnlen" },
	{ 0x75ca79b5, "__fortify_panic" },
	{ 0x8abaa33e, "btmtk_usb_setup" },
	{ 0xe36b561c, "usb_ifnum_to_if" },
	{ 0x4dfa8d4b, "mutex_lock" },
	{ 0x3fb6d105, "usb_driver_claim_interface" },
	{ 0x3213f038, "mutex_unlock" },
	{ 0xd9a5ea54, "__init_waitqueue_head" },
	{ 0x3bfab2e4, "devm_kmalloc" },
	{ 0xffeedf6a, "delayed_work_timer_fn" },
	{ 0xc6f46339, "init_timer_key" },
	{ 0x2c7150fb, "btintel_recv_event" },
	{ 0xfd049af3, "hci_alloc_dev_priv" },
	{ 0x1a93ce5f, "gpiod_get_optional" },
	{ 0xbd06be46, "btmtk_reset_sync" },
	{ 0xa5cb0ca4, "btmtk_set_bdaddr" },
	{ 0x6b1d3da9, "btmtk_usb_recv_acl" },
	{ 0xcf2511b5, "btmtk_usb_suspend" },
	{ 0x58308091, "btmtk_usb_resume" },
	{ 0xd590e1dc, "device_create_file" },
	{ 0x6b1c5d29, "hci_register_dev" },
	{ 0x9afda492, "debugfs_create_file" },
	{ 0x6dff3d05, "usb_match_id" },
	{ 0x1424d5b, "btintel_configure_setup" },
	{ 0xba49f2d8, "btbcm_setup_apple" },
	{ 0x9f106cf8, "btbcm_setup_patchram" },
	{ 0xacddd8af, "btbcm_set_bdaddr" },
	{ 0xeb04fce, "btrtl_set_driver_name" },
	{ 0x68187c0d, "btrtl_shutdown_realtek" },
	{ 0xd4835ef8, "dmi_check_system" },
	{ 0x8a05b330, "hci_devcd_register" },
	{ 0x218d1a09, "param_ops_bool" },
	{ 0xa93fc3ad, "default_llseek" },
	{ 0xe37f7be4, "simple_open" },
	{ 0xbdfb6dbb, "__fentry__" },
	{ 0x5b8239ca, "__x86_return_thunk" },
	{ 0x65487097, "__x86_indirect_thunk_rax" },
	{ 0x2e59bccc, "usb_register_driver" },
	{ 0x9996c2e6, "usb_alloc_urb" },
	{ 0x6d586b65, "usb_anchor_urb" },
	{ 0x6ebe366f, "ktime_get_mono_fast_ns" },
	{ 0xf264a1a6, "usb_submit_urb" },
	{ 0x2cf56265, "__dynamic_pr_debug" },
	{ 0x7b8c32f1, "bt_err" },
	{ 0x48db5758, "usb_unanchor_urb" },
	{ 0xc4aa18f, "kmalloc_caches" },
	{ 0xd8ba0fc0, "__kmalloc_cache_noprof" },
	{ 0xa2087e44, "usb_free_urb" },
	{ 0x52c5c991, "__kmalloc_noprof" },
	{ 0x7f02188f, "__msecs_to_jiffies" },
	{ 0xf1969a8e, "__usecs_to_jiffies" },
	{ 0x38b296ba, "hci_cmd_sync_cancel" },
	{ 0x34db050b, "_raw_spin_lock_irqsave" },
	{ 0xd35cce70, "_raw_spin_unlock_irqrestore" },
	{ 0x37a0cba, "kfree" },
	{ 0x8de6fe16, "sk_skb_reason_drop" },
	{ 0x8427cc7b, "_raw_spin_lock_irq" },
	{ 0x4b750f53, "_raw_spin_unlock_irq" },
	{ 0x3c12dfe, "cancel_work_sync" },
	{ 0x962c8ae1, "usb_kill_anchored_urbs" },
	{ 0xce2840e7, "irq_set_irq_wake" },
	{ 0xfcec0987, "enable_irq" },
	{ 0xd823ec53, "dev_kfree_skb_irq_reason" },
	{ 0xb1390d3, "usb_driver_release_interface" },
	{ 0xe783e261, "sysfs_emit" },
	{ 0x248efd3, "kstrtobool_from_user" },
	{ 0xf0fdf6cb, "__stack_chk_fail" },
	{ 0x619cb7dd, "simple_read_from_buffer" },
	{ 0x73e33847, "__hci_cmd_sync" },
	{ 0x29fcdd9, "skb_pull_data" },
	{ 0x718b8b7, "bt_info" },
	{ 0x214e4265, "bt_warn" },
	{ 0xbabfd1ea, "pm_runtime_allow" },
	{ 0xe0a77070, "__pm_runtime_suspend" },
	{ 0x8c5f64a6, "pm_runtime_forbid" },
	{ 0x87735e4d, "device_set_wakeup_capable" },
	{ 0xf9a482f9, "msleep" },
	{ 0x153c5873, "usb_enable_autosuspend" },
	{ 0xd2a5b63f, "usb_autopm_get_interface" },
	{ 0x4570a165, "usb_queue_reset_device" },
	{ 0xabb385b8, "gpiod_set_value_cansleep" },
	{ 0x93eba6e1, "btrtl_setup_realtek" },
	{ 0x73de708a, "__hci_cmd_sync_ev" },
	{ 0xb6ff6a40, "__hci_cmd_send" },
	{ 0xd091276b, "skb_pull" },
	{ 0x76e0b328, "hci_devcd_append" },
	{ 0x43aabb0c, "hci_devcd_complete" },
	{ 0x696d474d, "hci_devcd_init" },
	{ 0xe183ce4e, "usb_disable_autosuspend" },
	{ 0x407060c2, "hci_devcd_append_pattern" },
	{ 0x18fc2a0c, "hci_recv_frame" },
	{ 0x85da03be, "usb_control_msg" },
	{ 0xe5e3cb1f, "usb_bulk_msg" },
	{ 0x5d706d5c, "_dev_err" },
	{ 0x74602baa, "btmtk_usb_shutdown" },
	{ 0x116a4e5f, "skb_dequeue" },
	{ 0xf0130c1e, "usb_deregister" },
	{ 0xd0fae0b2, "usb_autopm_put_interface" },
	{ 0x656e4a6e, "snprintf" },
	{ 0xbf1981cb, "module_layout" },
};

MODULE_INFO(depends, "bluetooth,btmtk,usbcore,btintel,btbcm,btrtl");

MODULE_ALIAS("of:N*T*Cusb1286,204e");
MODULE_ALIAS("of:N*T*Cusb1286,204eC*");
MODULE_ALIAS("of:N*T*Cusbcf3,e300");
MODULE_ALIAS("of:N*T*Cusbcf3,e300C*");
MODULE_ALIAS("of:N*T*Cusb4ca,301a");
MODULE_ALIAS("of:N*T*Cusb4ca,301aC*");
MODULE_ALIAS("usb:v*p*d*dcE0dsc01dp01ic*isc*ip*in*");
MODULE_ALIAS("usb:v*p*d*dcE0dsc01dp04ic*isc*ip*in*");
MODULE_ALIAS("usb:v*p*d*dc*dsc*dp*icE0isc01ip01in*");
MODULE_ALIAS("usb:v05ACp*d*dc*dsc*dp*icFFisc01ip01in*");
MODULE_ALIAS("usb:v0E8Dp763Fd*dc*dsc*dp*ic*isc*ip*in*");
MODULE_ALIAS("usb:v0A5Cp21E1d*dc*dsc*dp*ic*isc*ip*in*");
MODULE_ALIAS("usb:v05ACp8213d*dc*dsc*dp*ic*isc*ip*in*");
MODULE_ALIAS("usb:v05ACp8215d*dc*dsc*dp*ic*isc*ip*in*");
MODULE_ALIAS("usb:v05ACp8218d*dc*dsc*dp*ic*isc*ip*in*");
MODULE_ALIAS("usb:v05ACp821Bd*dc*dsc*dp*ic*isc*ip*in*");
MODULE_ALIAS("usb:v05ACp821Fd*dc*dsc*dp*ic*isc*ip*in*");
MODULE_ALIAS("usb:v05ACp821Ad*dc*dsc*dp*ic*isc*ip*in*");
MODULE_ALIAS("usb:v05ACp8281d*dc*dsc*dp*ic*isc*ip*in*");
MODULE_ALIAS("usb:v057Cp3800d*dc*dsc*dp*ic*isc*ip*in*");
MODULE_ALIAS("usb:v04BFp030Ad*dc*dsc*dp*ic*isc*ip*in*");
MODULE_ALIAS("usb:v044Ep3001d*dc*dsc*dp*ic*isc*ip*in*");
MODULE_ALIAS("usb:v044Ep3002d*dc*dsc*dp*ic*isc*ip*in*");
MODULE_ALIAS("usb:v0BDBp1002d*dc*dsc*dp*ic*isc*ip*in*");
MODULE_ALIAS("usb:v0C10p0000d*dc*dsc*dp*ic*isc*ip*in*");
MODULE_ALIAS("usb:v19FFp0239d*dc*dsc*dp*ic*isc*ip*in*");
MODULE_ALIAS("usb:v105Bp*d*dc*dsc*dp*icFFisc01ip01in*");
MODULE_ALIAS("usb:v0BB4p*d*dc*dsc*dp*icFFisc01ip01in*");
MODULE_ALIAS("usb:v0489p*d*dc*dsc*dp*icFFisc01ip01in*");
MODULE_ALIAS("usb:v04CAp*d*dc*dsc*dp*icFFisc01ip01in*");
MODULE_ALIAS("usb:v0A5Cp*d*dc*dsc*dp*icFFisc01ip01in*");
MODULE_ALIAS("usb:v0B05p*d*dc*dsc*dp*icFFisc01ip01in*");
MODULE_ALIAS("usb:v050Dp*d*dc*dsc*dp*icFFisc01ip01in*");
MODULE_ALIAS("usb:v13D3p*d*dc*dsc*dp*icFFisc01ip01in*");
MODULE_ALIAS("usb:v413Cp*d*dc*dsc*dp*icFFisc01ip01in*");
MODULE_ALIAS("usb:v0930p*d*dc*dsc*dp*icFFisc01ip01in*");
MODULE_ALIAS("usb:v8087p0A5Ad*dc*dsc*dp*ic*isc*ip*in*");

MODULE_INFO(srcversion, "1A18977978E5D598D220382");
