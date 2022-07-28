"use strict";

Object.defineProperty(exports, "__esModule", { value: true });

const place_geo = [];

function initAutocomplete() {
  let name = document.getElementsByClassName("name");
  let lat = document.getElementsByClassName("lat");
  let lng = document.getElementsByClassName("lng");

  const place_geo_show = {
    lat: lat[0].value,
    name: name[0].value,
    lng: lng[0].value,
  };

  const map = new google.maps.Map(document.getElementById("map"), {
    center: {
      lat: parseFloat(place_geo_show.lat),
      lng: parseFloat(place_geo_show.lng),
    },
    zoom: 14,
    mapTypeId: "roadmap",
  });

  const input = document.getElementById("pac-input");
  const searchBox = new google.maps.places.SearchBox(input);
  map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);
  // Bias the SearchBox results towards current map's viewport.
  map.addListener("bounds_changed", function () {
    searchBox.setBounds(map.getBounds());
  });
  let markers = [];
  markers.push(
    new google.maps.Marker({
      map: map,
      name: place_geo_show.name,
      position: {
        lat: parseFloat(place_geo_show.lat),
        lng: parseFloat(place_geo_show.lng),
      },
      animation: google.maps.Animation.DROP,
    })
  );
  searchBox.addListener("places_changed", function () {
    document.getElementById("clear-pin").addEventListener("click", () => {
      // Clear out the old markers.
      markers.forEach(function (marker) {
        marker.setMap(null);
      });
    });
    var places = searchBox.getPlaces();
    if (places.length == 0) {
      return;
    }
    markers = [];
    // For each place, get the icon, name and location.
    var bounds = new google.maps.LatLngBounds();
    places.forEach(function (place) {
      if (!place.geometry || !place.geometry.location) {
        console.log("Returned place contains no geometry");
        return;
      }
      var icon = {
        size: new google.maps.Size(71, 71),
        origin: new google.maps.Point(0, 0),
        anchor: new google.maps.Point(17, 34),
        scaledSize: new google.maps.Size(25, 25),
      };
      // ピン　立てる
      markers.push(
        new google.maps.Marker({
          map: map,
          icon: icon,
          title: place.name,
          position: place.geometry.location,
          animation: google.maps.Animation.DROP,
        })
      );
      if (place.geometry.viewport) {
        // Only geocodes have viewport.
        bounds.union(place.geometry.viewport);
      } else {
        bounds.extend(place.geometry.location);
      }
      // 場所のlat,lngをもらってくる
      console.log(place.geometry["location"].lat());

      const place_ol = document.getElementById("place_ol");
      let str = document.createElement("li");
      str.innerHTML = place.name;
      place_ol.appendChild(str);

      place_geo.push({
        lat: place.geometry["location"].lat(),
        lng: place.geometry["location"].lng(),
        name: place.name,
      });

      const place_list = document.getElementById("place-list");
      let st = document.createElement("div");
      st.innerHTML = `
        <input type="hidden" name="lat" value="${place.geometry[
          "location"
        ].lat()}">
        <input type="hidden" name="lng" value="${place.geometry[
          "location"
        ].lng()}">
        <input type="hidden" name="name" value="${place.name}">
        `;
      place_list.appendChild(st);

      // console.log(place.geometry["location"].lng());
    });
    map.fitBounds(bounds);

    // ここでデータベースの方にplace_geoをアップデートするコードを作成
  });
}
window.initAutocomplete = initAutocomplete;
