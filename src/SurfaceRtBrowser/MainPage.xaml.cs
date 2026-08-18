using System;
using Windows.System;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Navigation;

namespace SurfaceRtBrowser
{
    public sealed partial class MainPage : Page
    {
        public MainPage()
        {
            InitializeComponent();
            Browser.NavigationCompleted += Browser_NavigationCompleted;
            Navigate("https://www.bing.com");
        }

        private void Go_Click(object sender, RoutedEventArgs e)
        {
            Navigate(AddressBar.Text);
        }

        private void AddressBar_KeyDown(object sender, KeyRoutedEventArgs e)
        {
            if (e.Key == VirtualKey.Enter)
            {
                Navigate(AddressBar.Text);
            }
        }

        private void Back_Click(object sender, RoutedEventArgs e)
        {
            if (Browser.CanGoBack) Browser.GoBack();
        }

        private void Forward_Click(object sender, RoutedEventArgs e)
        {
            if (Browser.CanGoForward) Browser.GoForward();
        }

        private void Browser_NavigationCompleted(WebView sender, WebViewNavigationCompletedEventArgs args)
        {
            if (args.Uri != null)
            {
                AddressBar.Text = args.Uri.AbsoluteUri;
            }
            BackButton.IsEnabled = Browser.CanGoBack;
            ForwardButton.IsEnabled = Browser.CanGoForward;
        }

        private void Navigate(string input)
        {
            if (string.IsNullOrWhiteSpace(input)) return;
            string url = input.Trim();
            if (!url.Contains("://"))
            {
                url = "https://" + url;
            }
            try
            {
                Browser.Navigate(new Uri(url, UriKind.Absolute));
            }
            catch
            {
            }
        }
    }
}