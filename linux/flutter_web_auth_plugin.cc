#include "include/flutter_web_auth/flutter_web_auth_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <webkit2/webkit2.h>
#include <string>
#include <sys/utsname.h>

#include <cstring>

#define FLUTTER_WEB_AUTH_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_web_auth_plugin_get_type(), \
                              FlutterWebAuthPlugin))

struct _FlutterWebAuthPlugin {
    GObject parent_instance;
    GtkWindow *window;
};


G_DEFINE_TYPE(FlutterWebAuthPlugin, flutter_web_auth_plugin, g_object_get_type())


static gboolean
navigate(WebKitWebView *web_view,
         WebKitLoadEvent load_event,
         gchar *failing_uri,
         gpointer error,
         gpointer user_data) {
    std::string url = failing_uri;
    auto method_call = static_cast<FlMethodCall*>(user_data);
    auto args = fl_method_call_get_args(method_call);
    auto callbackSchema = fl_value_get_string(fl_value_lookup_string(args, "callbackUrlScheme"));
    if (url.rfind(callbackSchema) == 0) {
        auto response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_string(failing_uri)));
        fl_method_call_respond(method_call, response, nullptr);
        auto parent = gtk_widget_get_parent(GTK_WIDGET(web_view));
        while(!GTK_IS_DIALOG(parent)) {
            parent = gtk_widget_get_parent(GTK_WIDGET(parent));
            if (parent == nullptr) return true;
        }
        gtk_dialog_response(GTK_DIALOG(parent), GTK_RESPONSE_ACCEPT);
        gtk_widget_destroy(GTK_WIDGET(parent));
        return true;
    }
    return false;
}


static GtkDialog*
open_authorize_dialog(gpointer parent, FlMethodCall* method_call) {
    auto dialog = gtk_dialog_new_with_buttons("Authorize",
                                              GTK_WINDOW(parent),
                                              GTK_DIALOG_MODAL,
                                              "_Cancel",
                                              GTK_RESPONSE_CANCEL,
                                              NULL);
    auto args = fl_method_call_get_args(method_call);
    auto url = fl_value_get_string(fl_value_lookup_string(args, "url"));

    // create a dialog with a webkit web view loading url inside
    auto content_area = gtk_dialog_get_content_area(GTK_DIALOG (dialog));
    auto web_view = webkit_web_view_new();
    auto scrolled = gtk_scrolled_window_new(nullptr, nullptr);
    gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scrolled), GTK_POLICY_ALWAYS, GTK_POLICY_ALWAYS);
    gtk_widget_set_size_request(scrolled, 480, 720);
    gtk_box_pack_start(GTK_BOX(content_area), scrolled, true, true, 0);
    gtk_container_add(GTK_CONTAINER(scrolled), web_view);
    webkit_web_view_load_uri(WEBKIT_WEB_VIEW(web_view), url);

    g_signal_connect(web_view, "load-failed", G_CALLBACK(navigate), g_object_ref(method_call));
    gtk_widget_show_all(dialog);

    return GTK_DIALOG(dialog);
}


// Called when a method call is received from Flutter.
static void flutter_web_auth_plugin_handle_method_call(
        FlutterWebAuthPlugin *self,
        FlMethodCall *method_call) {
    g_autoptr(FlMethodResponse) response = nullptr;

    const gchar *method = fl_method_call_get_name(method_call);

    if (strcmp(method, "getPlatformVersion") == 0) {
        struct utsname uname_data = {};
        uname(&uname_data);
        g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
        g_autoptr(FlValue) result = fl_value_new_string(version);
        response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    } else if (strcmp(method, "authenticate") == 0) {
        auto dialog = open_authorize_dialog(self->window, method_call);
        int result = gtk_dialog_run (GTK_DIALOG (dialog));
        if(result == GTK_RESPONSE_ACCEPT) {
            // response is already sent by webview
            return;
        }
        // not accepted, user canceled login
        gtk_widget_destroy(GTK_WIDGET(dialog));
        response = FL_METHOD_RESPONSE(fl_method_error_response_new("CANCELED", "User canceled login", nullptr));
    } else {
        response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
    }

    fl_method_call_respond(method_call, response, nullptr);
}

static void flutter_web_auth_plugin_dispose(GObject *object) {
    G_OBJECT_CLASS(flutter_web_auth_plugin_parent_class)->dispose(object);
}

static void flutter_web_auth_plugin_class_init(FlutterWebAuthPluginClass *klass) {
    G_OBJECT_CLASS(klass)->dispose = flutter_web_auth_plugin_dispose;
}

static void flutter_web_auth_plugin_init(FlutterWebAuthPlugin *self) {}

static void method_call_cb(FlMethodChannel *channel, FlMethodCall *method_call,
                           gpointer user_data) {
    FlutterWebAuthPlugin *plugin = FLUTTER_WEB_AUTH_PLUGIN(user_data);
    flutter_web_auth_plugin_handle_method_call(plugin, method_call);
}

void flutter_web_auth_plugin_register_with_registrar(FlPluginRegistrar *registrar) {
    FlutterWebAuthPlugin *plugin = FLUTTER_WEB_AUTH_PLUGIN(
            g_object_new(flutter_web_auth_plugin_get_type(), nullptr));

    FlView *view = fl_plugin_registrar_get_view(registrar);
    GtkWindow *window = nullptr;
    if (view != nullptr) {
        window =GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
    }
    plugin->window = window;

    g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
    g_autoptr(FlMethodChannel) channel =
                                       fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                                                             "flutter_web_auth",
                                                             FL_METHOD_CODEC(codec));
    fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                              g_object_ref(plugin),
                                              g_object_unref);

    g_object_unref(plugin);
}
